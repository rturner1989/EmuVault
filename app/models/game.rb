# == Schema Information
#
# Table name: games
#
#  id         :bigint           not null, primary key
#  rom_hash   :string
#  system     :string           not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_games_on_rom_hash  (rom_hash)
#
class Game < ApplicationRecord
  include HasGameSystem

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

  enum :system, GAME_SYSTEMS.index_with(&:to_s)

  has_many :game_saves, dependent: :destroy
  has_many :game_emulator_configs, dependent: :destroy

  validates :title, presence: true
  validates :system, presence: true

  def system_label
    self.class.game_system_label(system)
  end

  def system_badge_color
    SYSTEM_COLORS.fetch(system&.to_sym, :comment)
  end

  def default_save_base_name
    title.gsub(/[^0-9A-Za-z\-_ .()]/, "").strip.squeeze(" ")
  end
end
