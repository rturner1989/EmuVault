# frozen_string_literal: true

require "zip"

class DataImportJob < ApplicationJob
  queue_as :default

  def perform(data_import_id)
    import = DataImport.find(data_import_id)
    import.update!(status: :importing)

    manifest = import.manifest
    resolutions = import.resolutions || {}
    result = { imported: 0, skipped: 0, failed: 0 }

    Array(manifest["emulator_profiles"]).each { |profile_data| restore_profile(profile_data) }

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

  private def import_game(zip, game_data, resolutions, result)
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

    game_data["saves"].each { |save_data| restore_save(zip, game, save_data) }
    game_data.fetch("emulator_configs", []).each { |config_data| restore_emulator_config(game, config_data) }
    result[:imported] += 1
  rescue => e
    Rails.logger.error "[DataImportJob] Failed to import game #{game_data["title"]}: #{e.message}"
    result[:failed] += 1
  end

  private def restore_profile(profile_data)
    lookup = { name: profile_data["name"], platform: profile_data["platform"] }
    lookup[:game_system] = profile_data["game_system"] if profile_data["game_system"].present?

    profiles = EmulatorProfile.where(lookup)

    if profiles.any?
      profiles.update_all(user_selected: true)
    else
      EmulatorProfile.create!(
        name: profile_data["name"],
        platform: profile_data["platform"],
        game_system: profile_data["game_system"],
        save_extension: profile_data["save_extension"],
        default_save_path: profile_data["default_save_path"],
        is_default: false,
        user_selected: true
      )
    end
  rescue => e
    Rails.logger.error "[DataImportJob] Failed to restore profile #{profile_data["name"]}: #{e.message}"
  end

  private def restore_emulator_config(game, config_data)
    profile = EmulatorProfile.find_by(name: config_data["emulator_profile_name"])
    return unless profile

    game.game_emulator_configs.find_or_initialize_by(emulator_profile: profile).tap do |config|
      config.save_filename = config_data["save_filename"]
      config.save!
    end
  end

  private def restore_save(zip, game, save_data)
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
