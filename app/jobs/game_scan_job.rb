class GameScanJob < ApplicationJob
  queue_as :default

  # Known ROM file extensions per system.
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

  # mode: "dry_run"  — discover ROMs, store findings, no DB writes
  # mode: "confirm"  — import a specific list of items (from review step)
  # mode: "auto"     — import all new ROMs from auto_scan paths (scheduled)
  def perform(mode = "auto", items = nil)
    user = User.first

    case mode
    when "dry_run"
      result = collect_roms(ScanPath.ordered)
      result["status"] = "pending_review"
      user.update!(last_scan_result: result)

    when "confirm"
      result = import_items(items || [])
      result["status"] = "completed"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)

    when "auto"
      return unless user.scan_enabled? && scan_due?(user)

      result = import_roms(ScanPath.for_auto_scan)
      result["status"] = "completed"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)

    when "auto_all"
      result = import_roms(ScanPath.ordered)
      result["status"] = "completed"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)
      return result
    end
  end

  private def scan_due?(user)
    return true if user.last_scanned_at.nil?

    interval = case user.scan_interval.to_s
    when "every_6_hours" then 6.hours
    when "daily"         then 1.day
    else                      1.hour
    end

    user.last_scanned_at < interval.ago
  end

  # Walk scan paths and collect ROM discoveries without touching the DB.
  private def collect_roms(scan_paths)
    found = []
    already_in_lib = 0
    skipped_paths = []

    save_extensions = active_save_extensions

    scan_paths.each do |sp|
      unless Dir.exist?(sp.path)
        skipped_paths << { "id" => sp.id, "path" => sp.path, "system" => sp.game_system.to_s }
        next
      end

      rom_exts = ROM_EXTENSIONS[sp.game_system.to_s] || []

      Dir.glob(File.join(sp.path, "**", "*")).each do |file_path|
        next unless File.file?(file_path)

        ext = File.extname(file_path).delete_prefix(".").downcase
        next unless rom_exts.include?(ext)

        title = titleize(file_path)

        if Game.exists?(title: title, system: sp.game_system.to_s)
          already_in_lib += 1
          next
        end

        save_files = find_save_files(file_path, save_extensions)

        found << {
          "rom_path"      => file_path,
          "scan_path_id"  => sp.id,
          "game_system"   => sp.game_system.to_s,
          "title"         => title,
          "size"          => File.size(file_path),
          "save_files"    => save_files
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

  # Import a specific list of items confirmed by the user.
  private def import_items(items)
    added = 0
    errors = []

    items.each do |item|
      begin
        import_rom(item)
        added += 1
      rescue => e
        errors << { "rom" => item["rom_path"], "error" => e.message }
      end
    end

    { "added" => added, "errors" => errors }
  end

  # Walk auto_scan paths and import all newly discovered ROMs.
  private def import_roms(scan_paths)
    added = 0
    skipped = 0
    errors = []

    save_extensions = active_save_extensions

    scan_paths.each do |sp|
      next unless Dir.exist?(sp.path)

      rom_exts = ROM_EXTENSIONS[sp.game_system.to_s] || []

      Dir.glob(File.join(sp.path, "**", "*")).each do |file_path|
        next unless File.file?(file_path)

        ext = File.extname(file_path).delete_prefix(".").downcase
        next unless rom_exts.include?(ext)

        title = titleize(file_path)

        if Game.exists?(title: title, system: sp.game_system.to_s)
          skipped += 1
          next
        end

        save_files = find_save_files(file_path, save_extensions)

        begin
          import_rom({
            "rom_path"    => file_path,
            "game_system" => sp.game_system.to_s,
            "title"       => title,
            "save_files"  => save_files
          })
          added += 1
        rescue => e
          errors << { "rom" => file_path, "error" => e.message }
        end
      end
    end

    { "added" => added, "skipped" => skipped, "errors" => errors }
  end

  private def import_rom(item)
    game = Game.create!(title: item["title"], system: item["game_system"])

    (item["save_files"] || []).each do |save_file|
      next unless File.exist?(save_file["path"])

      checksum = Digest::SHA256.file(save_file["path"]).hexdigest
      next if GameSave.exists?(checksum: checksum)

      profile = EmulatorProfile.where(user_selected: true)
                               .find_by(save_extension: save_file["extension"])

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
  end

  # Look for save files alongside a ROM with matching base name.
  private def find_save_files(rom_path, save_extensions)
    dir = File.dirname(rom_path)
    base_name = File.basename(rom_path, ".*")
    found = []

    save_extensions.each do |ext|
      candidate = File.join(dir, "#{base_name}.#{ext}")
      next unless File.exist?(candidate)

      found << {
        "path"      => candidate,
        "extension" => ext,
        "size"      => File.size(candidate)
      }
    end

    found
  end

  private def active_save_extensions
    EmulatorProfile.where(user_selected: true).pluck(:save_extension).uniq
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
