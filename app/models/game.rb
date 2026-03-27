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

  has_one_attached :cover_image
  has_many :game_saves, dependent: :destroy
  has_many :game_emulator_configs, dependent: :destroy

  validates :title, presence: true
  validates :system, presence: true
  validate :acceptable_cover_image, if: -> { cover_image.attached? }

  def system_label
    self.class.game_system_label(system)
  end

  def system_badge_color
    SYSTEM_COLORS.fetch(system&.to_sym, :comment)
  end

  def default_save_base_name
    title.gsub(/[^0-9A-Za-z\-_ .()]/, "").strip.squeeze(" ")
  end

  private def acceptable_cover_image
    unless cover_image.content_type.in?(%w[image/png image/jpeg image/webp])
      errors.add(:cover_image, "must be PNG, JPEG, or WebP")
    end

    if cover_image.byte_size > 5.megabytes
      errors.add(:cover_image, "must be less than 5 MB")
    end
  end
end
