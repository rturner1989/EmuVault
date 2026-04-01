# frozen_string_literal: true

# Discovers and imports ROM files from scan paths.
# Used by scan jobs (GameScanDryRunJob, GameScanConfirmJob, GameAutoScanJob, GameScanImportAllJob).
class GameScanner
  ROM_EXTENSIONS = {
    "nes"     => %w[nes],
    "snes"    => %w[sfc smc],
    "gb"      => %w[gb],
    "gbc"     => %w[gbc],
    "gba"     => %w[gba],
    "nds"     => %w[nds],
    "genesis" => %w[md bin gen],
    "sms"     => %w[sms],
    "gg"      => %w[gg],
    "psx"     => %w[bin iso img cue],
    "ps2"     => %w[iso],
    "psp"     => %w[iso cso],
    "n64"     => %w[n64 z64 v64],
    "gc"      => %w[iso gcm],
    "wii"     => %w[iso wbfs],
    "arcade"  => %w[zip]
  }.freeze

  # Discover ROMs without touching the DB — returns a hash of findings.
  def collect(scan_paths)
    found = []
    already_in_lib = 0
    skipped_paths = []

    save_extensions = active_save_extensions

    scan_paths.each do |sp|
      unless Dir.exist?(sp.path)
        skipped_paths << { "id" => sp.id, "path" => sp.path, "system" => sp.game_system.to_s }
        next
      end

      each_rom(sp) do |file_path, title|
        if Game.exists?(title: title, system: sp.game_system.to_s)
          already_in_lib += 1
          next
        end

        found << {
          "rom_path"      => file_path,
          "scan_path_id"  => sp.id,
          "game_system"   => sp.game_system.to_s,
          "title"         => title,
          "size"          => File.size(file_path),
          "save_files"    => find_save_files(file_path, save_extensions)
        }
      end
    end

    {
      "found"          => found,
      "already_in_lib" => already_in_lib,
      "skipped_paths"  => skipped_paths,
      "errors"         => []
    }
  end

  # Import all newly discovered ROMs from scan paths.
  # Yields each imported game for real-time updates.
  def import_all(scan_paths, &block)
    added = 0
    skipped = 0
    errors = []

    save_extensions = active_save_extensions

    scan_paths.each do |sp|
      next unless Dir.exist?(sp.path)

      each_rom(sp) do |file_path, title|
        if Game.exists?(title: title, system: sp.game_system.to_s)
          skipped += 1
          next
        end

        begin
          game = import_rom(
            "rom_path" => file_path,
            "game_system" => sp.game_system.to_s,
            "title" => title,
            "save_files" => find_save_files(file_path, save_extensions)
          )
          added += 1
          block&.call(game)
        rescue => e
          errors << { "rom" => file_path, "error" => e.message }
        end
      end
    end

    { "added" => added, "skipped" => skipped, "errors" => errors }
  end

  # Import a specific list of items (from the review/confirm step).
  # Yields each imported game for real-time updates.
  def import_items(items, &block)
    added = 0
    errors = []

    items.each do |item|
      begin
        game = import_rom(item)
        added += 1
        block&.call(game)
      rescue => e
        errors << { "rom" => item["rom_path"], "error" => e.message }
      end
    end

    { "added" => added, "errors" => errors }
  end

  private def import_rom(item)
    game = Game.find_or_create_by!(title: item["title"], system: item["game_system"])

    (item["save_files"] || []).each do |save_file|
      next unless File.exist?(save_file["path"])

      checksum = Digest::SHA256.file(save_file["path"]).hexdigest
      next if GameSave.exists?(checksum: checksum)

      profile = EmulatorProfile.user_selected.find_by(save_extension: save_file["extension"])

      game_save = game.game_saves.build(
        emulator_profile: profile,
        checksum: checksum,
        saved_at: File.mtime(save_file["path"])
      )
      game_save.file.attach(
        io: File.open(save_file["path"], "rb"),
        filename: File.basename(save_file["path"])
      )
      game_save.save!
    end

    game
  end

  private def each_rom(scan_path)
    rom_exts = ROM_EXTENSIONS[scan_path.game_system.to_s] || []

    Dir.glob(File.join(scan_path.path, "**", "*")).each do |file_path|
      next unless File.file?(file_path)

      ext = File.extname(file_path).delete_prefix(".").downcase
      next unless rom_exts.include?(ext)

      yield file_path, titleize(file_path)
    end
  end

  private def find_save_files(rom_path, save_extensions)
    dir = File.dirname(rom_path)
    base_name = File.basename(rom_path, ".*")

    save_extensions.filter_map do |ext|
      candidate = File.join(dir, "#{base_name}.#{ext}")
      next unless File.exist?(candidate)

      { "path" => candidate, "extension" => ext, "size" => File.size(candidate) }
    end
  end

  private def active_save_extensions
    EmulatorProfile.user_selected.pluck(:save_extension).uniq
  end

  private def titleize(file_path)
    File.basename(file_path, ".*")
        .gsub(/[_\-]/, " ")
        .gsub(/\s+/, " ")
        .strip
        .split
        .map(&:capitalize)
        .join(" ")
  end
end
