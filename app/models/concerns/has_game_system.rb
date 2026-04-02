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

  class_methods do
    def game_system_label(value)
      I18n.t("models.game_system.#{value}", default: value.to_s.upcase)
    end

    def game_system_options
      GAME_SYSTEMS.map { |s| [ game_system_label(s), s.to_s ] }
    end
  end
end
