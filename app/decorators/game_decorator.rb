# frozen_string_literal: true

class GameDecorator < ApplicationDecorator
  SYSTEM_COLORS = {
    nes: :purple,
    snes: :purple,
    n64: :purple,
    gc: :purple,
    wii: :purple,
    gb: :green,
    gbc: :green,
    gba: :green,
    nds: :green,
    genesis: :yellow,
    sms: :yellow,
    gg: :yellow,
    psx: :cyan,
    ps2: :cyan,
    psp: :cyan,
    arcade: :pink
  }.freeze

  def system_label
    object.system&.text || "Unknown"
  end

  def system_badge_color
    SYSTEM_COLORS.fetch(object.system&.to_sym, :comment)
  end
end
