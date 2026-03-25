# frozen_string_literal: true

module HasGameSystem
  extend ActiveSupport::Concern

  GAME_SYSTEMS = %i[
    nes snes gb gbc gba nds
    genesis sms gg
    psx ps2 psp
    n64 gc wii
    arcade
  ].freeze

  GAME_SYSTEM_LABELS = {
    nes: "NES",
    snes: "SNES",
    gb: "Game Boy",
    gbc: "Game Boy Color",
    gba: "Game Boy Advance",
    nds: "Nintendo DS",
    genesis: "Sega Genesis",
    sms: "Sega Master System",
    gg: "Game Gear",
    psx: "PlayStation",
    ps2: "PlayStation 2",
    psp: "PlayStation Portable",
    n64: "Nintendo 64",
    gc: "GameCube",
    wii: "Wii",
    arcade: "Arcade"
  }.freeze

  GAME_SYSTEM_OPTIONS = GAME_SYSTEMS.map { |s| [ GAME_SYSTEM_LABELS[s], s.to_s ] }.freeze

  class_methods do
    def game_system_label(value)
      GAME_SYSTEM_LABELS[value.to_sym] || value.to_s.upcase
    end
  end
end
