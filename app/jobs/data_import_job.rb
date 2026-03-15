# frozen_string_literal: true

require "zip"

class DataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import_id)
    import = DataImport.find(data_import_id)
    import.update!(status: :importing)

    manifest   = import.manifest
    resolutions = import.resolutions || {}
    result     = { imported: 0, skipped: 0, failed: 0 }

    import.file.open do |tmp|
      Zip::File.open(tmp.path) do |zip|
        manifest["games"].each do |game_data|
          import_game(zip, game_data, resolutions, result)
        end
      end
    end

    import.update!(status: :complete, result: result)
  rescue => e
    import&.update(status: :failed, result: { error: e.message })
    raise
  end

  private

  def import_game(zip, game_data, resolutions, result)
    existing = Game.find_by(title: game_data["title"], system: game_data["system"])
    resolution = resolutions[game_data["export_id"]]

    if existing
      if resolution == "replace"
        existing.game_saves.destroy_all
        game = existing
      else
        # "skip" or no resolution — keep existing
        result[:skipped] += 1
        return
      end
    else
      game = Game.create!(title: game_data["title"], system: game_data["system"])
    end

    game_data["saves"].each { restore_save(zip, game, _1) }
    game_data.fetch("emulator_configs", []).each { restore_emulator_config(game, _1) }
    result[:imported] += 1
  rescue => e
    Rails.logger.error "[DataImportJob] Failed to import game #{game_data["title"]}: #{e.message}"
    result[:failed] += 1
  end

  def restore_emulator_config(game, config_data)
    profile = EmulatorProfile.find_by(name: config_data["emulator_profile_name"])
    return unless profile

    game.game_emulator_configs.find_or_initialize_by(emulator_profile: profile).tap do |config|
      config.save_filename = config_data["save_filename"]
      config.save!
    end
  end

  def restore_save(zip, game, save_data)
    entry = zip.find_entry(save_data["file_path"])
    return unless entry

    profile = EmulatorProfile.find_by(name: save_data["emulator_profile_name"])

    Tempfile.create([ "import", File.extname(save_data["file_path"]) ], binmode: true) do |tmp|
      tmp.write(entry.get_input_stream.read)
      tmp.rewind

      game_save = game.game_saves.build(
        saved_at: save_data["saved_at"],
        checksum: save_data["checksum"],
        emulator_profile: profile
      )
      game_save.file.attach(
        io: tmp,
        filename: File.basename(save_data["file_path"]),
        content_type: "application/octet-stream"
      )
      game_save.save!
    end
  end
end
