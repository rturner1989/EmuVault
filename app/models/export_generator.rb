# frozen_string_literal: true

require "zip"

class ExportGenerator
  def initialize(games)
    @games = games
  end

  def generate
    buffer = Zip::OutputStream.write_buffer do |zip|
      zip.put_next_entry("manifest.json")
      zip.write(build_manifest.to_json)

      @games.each do |game|
        game.game_saves.latest_first.each do |save|
          next unless save.file.attached?

          ext = save.file.filename.extension_without_delimiter
          zip.put_next_entry("saves/#{game.id}/#{save.id}.#{ext}")
          zip.write(save.file.download)
        end
      end
    end

    buffer.string
  end

  private def build_manifest
    {
      exported_at: Time.current.iso8601,
      app_version: Rails.application.config.app_version,
      games: @games.map { |game| serialize_game(game) },
      emulator_profiles: EmulatorProfile.user_selected.map { |profile| serialize_profile(profile) }
    }
  end

  private def serialize_game(game)
    {
      export_id: game.id.to_s,
      title: game.title,
      system: game.system,
      saves: game.game_saves.latest_first.map { |save| serialize_save(game, save) },
      emulator_configs: game.game_emulator_configs.map { |config| serialize_emulator_config(config) }
    }
  end

  private def serialize_save(game, save)
    ext = save.file.attached? ? save.file.filename.extension_without_delimiter : "sav"
    {
      export_id: save.id.to_s,
      saved_at: save.saved_at&.iso8601,
      checksum: save.checksum,
      emulator_profile_name: save.emulator_profile&.name,
      file_path: "saves/#{game.id}/#{save.id}.#{ext}"
    }
  end

  private def serialize_emulator_config(config)
    {
      emulator_profile_name: config.emulator_profile.name,
      save_filename: config.save_filename
    }
  end

  private def serialize_profile(profile)
    {
      name: profile.name,
      platform: profile.platform,
      game_system: profile.game_system,
      save_extension: profile.save_extension,
      default_save_path: profile.default_save_path
    }
  end
end
