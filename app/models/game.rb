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
