class GameSave < ApplicationRecord
  belongs_to :game
  belongs_to :emulator_profile

  has_many :sync_events, dependent: :destroy
  has_one_attached :file

  validates :slot, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :slot, uniqueness: { scope: %i[game_id emulator_profile_id] }
end
