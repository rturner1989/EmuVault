class EmulatorProfile < ApplicationRecord
  extend Enumerize

  enumerize :platform, in: %i[linux windows macos ios android], predicates: true

  has_many :game_saves, dependent: :destroy

  validates :name, presence: true
  validates :platform, presence: true
  validates :save_extension, presence: true
  validates :name, uniqueness: { scope: :platform }
end
