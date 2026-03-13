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
  extend Enumerize

  enumerize :system, in: %i[
    nes snes gb gbc gba nds
    genesis sms gg
    psx ps2 psp
    n64 gc wii
    arcade
  ], predicates: true

  has_many :game_saves, dependent: :destroy

  validates :title, presence: true
  validates :system, presence: true
end
