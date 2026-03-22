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
end
