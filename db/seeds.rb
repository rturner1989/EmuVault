# frozen_string_literal: true

# No user is seeded — the first user is created via the registration page on first load.

# =============================================================================
# Emulator profiles
#
# Structure: each emulator defines:
#   - platforms: hash of { platform_sym => default_save_path }
#   - systems:   hash of { game_system_sym => save_extension }
#
# A profile row is generated for every platform × system combination.
# Save paths are per-platform (same directory regardless of system).
# Extensions are per-system (different cores/formats per system).
# =============================================================================
EMULATOR_DEFINITIONS = [
  # ---------------------------------------------------------------------------
  # RetroArch — multi-system frontend, different cores per system
  # Extensions vary by core: mGBA/Gambatte use .sav, most others .srm,
  # Mupen64Plus-Next uses .sra, Dolphin core uses .gci, PPSSPP core uses .bin
  # ---------------------------------------------------------------------------
  {
    name: "RetroArch",
    platforms: {
      linux:   "~/.config/retroarch/saves",
      windows: "%APPDATA%/RetroArch/saves",
      macos:   "~/Library/Application Support/RetroArch/saves",
      android: "/storage/emulated/0/RetroArch/saves"
    },
    systems: {
      nes:     "srm",  # FCEUmm / Nestopia UE
      snes:    "srm",  # Snes9x / bsnes
      gb:      "sav",  # Gambatte / mGBA
      gbc:     "sav",  # Gambatte / mGBA
      gba:     "srm",  # mGBA (RetroArch mGBA core outputs .srm)
      nds:     "sav",  # melonDS core
      genesis: "srm",  # Genesis Plus GX
      sms:     "srm",  # Genesis Plus GX
      gg:      "srm",  # Genesis Plus GX
      psx:     "srm",  # PCSX-ReARMed / Beetle PSX HW
      psp:     "bin",  # PPSSPP core
      n64:     "sra",  # Mupen64Plus-Next (SRAM saves; most common battery type)
      gc:      "gci",  # Dolphin core
      arcade:  "sav"   # FinalBurn Neo / MAME
    }
  },

  # ---------------------------------------------------------------------------
  # Delta — iOS multi-system emulator (Nintendo systems only)
  # Uses Mupen64Plus for N64, MelonDS for DS
  # ---------------------------------------------------------------------------
  {
    name: "Delta",
    platforms: {
      ios: nil
    },
    systems: {
      nes:  "sav",
      snes: "srm",
      gb:   "sav",
      gbc:  "sav",
      gba:  "sav",
      n64:  "sav",
      nds:  "dsv"   # melonDS .dsv format
    }
  },

  # ---------------------------------------------------------------------------
  # mGBA — standalone GBA / GB / GBC emulator
  # ---------------------------------------------------------------------------
  {
    name: "mGBA",
    platforms: {
      linux:   "~/.config/mgba",
      windows: "%APPDATA%/mGBA",
      macos:   "~/Library/Application Support/mGBA",
      android: "/storage/emulated/0/mGBA/saves"
    },
    systems: {
      gb:  "sav",
      gbc: "sav",
      gba: "sav"
    }
  },

  # ---------------------------------------------------------------------------
  # Dolphin — GameCube and Wii emulator
  # GC: single .gci memory card export
  # Wii: .bin export (individual game save)
  # ---------------------------------------------------------------------------
  {
    name: "Dolphin",
    platforms: {
      linux:   "~/.local/share/dolphin-emu/GC",
      windows: "%APPDATA%/Dolphin Emulator/GC",
      macos:   "~/Library/Application Support/Dolphin/GC"
    },
    systems: {
      gc:  "gci",
      wii: "bin"
    }
  },

  # ---------------------------------------------------------------------------
  # PPSSPP — PSP emulator
  # ---------------------------------------------------------------------------
  {
    name: "PPSSPP",
    platforms: {
      linux:   "~/.config/ppsspp/PSP/SAVEDATA",
      windows: "%APPDATA%/PPSSPP/PSP/SAVEDATA",
      macos:   "~/Library/Application Support/PPSSPP/PSP/SAVEDATA",
      android: "/storage/emulated/0/PSP/SAVEDATA",
      ios:     nil
    },
    systems: {
      psp: "bin"
    }
  },

  # ---------------------------------------------------------------------------
  # melonDS — standalone Nintendo DS emulator
  # ---------------------------------------------------------------------------
  {
    name: "melonDS",
    platforms: {
      linux:   "~/.config/melonDS",
      windows: "%APPDATA%/melonDS",
      macos:   "~/Library/Application Support/melonDS"
    },
    systems: {
      nds: "sav"
    }
  },

  # ---------------------------------------------------------------------------
  # Snes9x — standalone SNES emulator
  # ---------------------------------------------------------------------------
  {
    name: "Snes9x",
    platforms: {
      linux:   "~/.snes9x",
      windows: "%APPDATA%/Snes9x",
      macos:   "~/Library/Application Support/Snes9x"
    },
    systems: {
      snes: "srm"
    }
  },

  # ---------------------------------------------------------------------------
  # OpenEmu — macOS all-in-one emulator frontend
  # Uses system-specific plugins (Beetle PSX → .mcr, DeSmuME/melonDS → .dsv, etc.)
  # ---------------------------------------------------------------------------
  {
    name: "OpenEmu",
    platforms: {
      macos: "~/Library/Application Support/OpenEmu/Battery Saves"
    },
    systems: {
      nes:     "sav",
      snes:    "srm",
      gb:      "sav",
      gbc:     "sav",
      gba:     "sav",
      nds:     "dsv",  # DeSmuME / melonDS plugin
      genesis: "sav",  # Genesis Plus GX plugin
      sms:     "sav",
      gg:      "sav",
      psx:     "mcr",  # Beetle PSX plugin
      gc:      "gci",  # Dolphin plugin
      n64:     "sav"   # Mupen64Plus plugin
    }
  },

  # ---------------------------------------------------------------------------
  # DuckStation — PS1 emulator (.mcd = memory card)
  # ---------------------------------------------------------------------------
  {
    name: "DuckStation",
    platforms: {
      linux:   "~/.local/share/duckstation/memcards",
      windows: "%APPDATA%/DuckStation/memcards",
      macos:   "~/Library/Application Support/DuckStation/memcards",
      android: "/storage/emulated/0/DuckStation/memcards"
    },
    systems: {
      psx: "mcd"
    }
  },

  # ---------------------------------------------------------------------------
  # PCSX2 — PS2 emulator (.ps2 = memory card)
  # ---------------------------------------------------------------------------
  {
    name: "PCSX2",
    platforms: {
      linux:   "~/.config/PCSX2/memcards",
      windows: "%APPDATA%/PCSX2/memcards",
      macos:   "~/Library/Application Support/PCSX2/memcards"
    },
    systems: {
      ps2: "ps2"
    }
  }
].freeze

# Clear existing default profiles and regenerate from the definition above.
# Nullify FK references before deleting so constraints don't block us.
default_profile_ids = EmulatorProfile.where(is_default: true).pluck(:id)
if default_profile_ids.any?
  GameSave.where(emulator_profile_id: default_profile_ids).update_all(emulator_profile_id: nil)
  GameEmulatorConfig.where(emulator_profile_id: default_profile_ids).delete_all
  EmulatorProfile.where(id: default_profile_ids).delete_all
end

EMULATOR_DEFINITIONS.each do |emulator|
  emulator[:platforms].each do |platform, save_path|
    emulator[:systems].each do |game_system, save_extension|
      EmulatorProfile.create!(
        name:             emulator[:name],
        platform:         platform,
        game_system:      game_system,
        save_extension:   save_extension,
        default_save_path: save_path,
        is_default:       true,
        user_selected:    false
      )
    end
  end
end

puts "Emulator profiles ready: #{EmulatorProfile.count} total (#{EmulatorProfile.where(is_default: true).count} default)"
