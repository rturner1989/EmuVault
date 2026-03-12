# =============================================================================
# Admin user
# =============================================================================
admin_email    = ENV.fetch("ADMIN_EMAIL") { raise "ADMIN_EMAIL env var is required" }
admin_password = ENV.fetch("ADMIN_PASSWORD") { raise "ADMIN_PASSWORD env var is required" }

User.find_or_initialize_by(email_address: admin_email).tap do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.save!
  puts "Admin user ready: #{admin_email}"
end

# =============================================================================
# Emulator profiles
# =============================================================================
profiles = [
  # ---------------------------------------------------------------------------
  # RetroArch — multi-system frontend, .srm is the standard battery-save format
  # ---------------------------------------------------------------------------
  { name: "RetroArch", platform: :linux,   save_extension: "srm", default_save_path: "~/.config/retroarch/saves" },
  { name: "RetroArch", platform: :windows, save_extension: "srm", default_save_path: "%APPDATA%/RetroArch/saves" },
  { name: "RetroArch", platform: :macos,   save_extension: "srm", default_save_path: "~/Library/Application Support/RetroArch/saves" },
  { name: "RetroArch", platform: :android, save_extension: "srm", default_save_path: "/storage/emulated/0/RetroArch/saves" },

  # ---------------------------------------------------------------------------
  # Delta — iOS multi-system emulator (NES, SNES, GBA, GBC, N64, DS)
  # ---------------------------------------------------------------------------
  { name: "Delta", platform: :ios, save_extension: "sav", default_save_path: nil },

  # ---------------------------------------------------------------------------
  # mGBA — standalone GBA/GB/GBC emulator
  # ---------------------------------------------------------------------------
  { name: "mGBA", platform: :linux,   save_extension: "sav", default_save_path: "~/.config/mgba" },
  { name: "mGBA", platform: :windows, save_extension: "sav", default_save_path: "%APPDATA%/mGBA" },
  { name: "mGBA", platform: :macos,   save_extension: "sav", default_save_path: "~/Library/Application Support/mGBA" },
  { name: "mGBA", platform: :android, save_extension: "sav", default_save_path: "/storage/emulated/0/mGBA/saves" },

  # ---------------------------------------------------------------------------
  # Dolphin — GameCube / Wii emulator (.gci = GameCube memory card export)
  # ---------------------------------------------------------------------------
  { name: "Dolphin", platform: :linux,   save_extension: "gci", default_save_path: "~/.local/share/dolphin-emu/GC" },
  { name: "Dolphin", platform: :windows, save_extension: "gci", default_save_path: "%APPDATA%/Dolphin Emulator/GC" },
  { name: "Dolphin", platform: :macos,   save_extension: "gci", default_save_path: "~/Library/Application Support/Dolphin/GC" },

  # ---------------------------------------------------------------------------
  # PPSSPP — PSP emulator (saves stored as .bin inside SAVEDATA folders)
  # ---------------------------------------------------------------------------
  { name: "PPSSPP", platform: :android, save_extension: "bin", default_save_path: "/storage/emulated/0/PSP/SAVEDATA" },
  { name: "PPSSPP", platform: :ios,     save_extension: "bin", default_save_path: nil },
  { name: "PPSSPP", platform: :linux,   save_extension: "bin", default_save_path: "~/.config/ppsspp/PSP/SAVEDATA" },
  { name: "PPSSPP", platform: :windows, save_extension: "bin", default_save_path: "%APPDATA%/PPSSPP/PSP/SAVEDATA" },
  { name: "PPSSPP", platform: :macos,   save_extension: "bin", default_save_path: "~/Library/Application Support/PPSSPP/PSP/SAVEDATA" },

  # ---------------------------------------------------------------------------
  # melonDS — Nintendo DS emulator
  # ---------------------------------------------------------------------------
  { name: "melonDS", platform: :linux,   save_extension: "sav", default_save_path: "~/.config/melonDS" },
  { name: "melonDS", platform: :windows, save_extension: "sav", default_save_path: "%APPDATA%/melonDS" },
  { name: "melonDS", platform: :macos,   save_extension: "sav", default_save_path: "~/Library/Application Support/melonDS" },

  # ---------------------------------------------------------------------------
  # Snes9x — standalone SNES emulator
  # ---------------------------------------------------------------------------
  { name: "Snes9x", platform: :linux,   save_extension: "srm", default_save_path: "~/.snes9x" },
  { name: "Snes9x", platform: :windows, save_extension: "srm", default_save_path: "%APPDATA%/Snes9x" },
  { name: "Snes9x", platform: :macos,   save_extension: "srm", default_save_path: "~/Library/Application Support/Snes9x" },

  # ---------------------------------------------------------------------------
  # OpenEmu — macOS all-in-one emulator frontend
  # ---------------------------------------------------------------------------
  { name: "OpenEmu", platform: :macos, save_extension: "sav", default_save_path: "~/Library/Application Support/OpenEmu/Battery Saves" },

  # ---------------------------------------------------------------------------
  # DuckStation — PS1 emulator
  # ---------------------------------------------------------------------------
  { name: "DuckStation", platform: :linux,   save_extension: "mcd", default_save_path: "~/.local/share/duckstation/memcards" },
  { name: "DuckStation", platform: :windows, save_extension: "mcd", default_save_path: "%APPDATA%/DuckStation/memcards" },
  { name: "DuckStation", platform: :macos,   save_extension: "mcd", default_save_path: "~/Library/Application Support/DuckStation/memcards" },
  { name: "DuckStation", platform: :android, save_extension: "mcd", default_save_path: "/storage/emulated/0/DuckStation/memcards" }
]

profiles.each do |attrs|
  EmulatorProfile.find_or_create_by!(name: attrs[:name], platform: attrs[:platform]) do |profile|
    profile.save_extension   = attrs[:save_extension]
    profile.default_save_path = attrs[:default_save_path]
  end
end

puts "Emulator profiles ready: #{EmulatorProfile.count} total"
