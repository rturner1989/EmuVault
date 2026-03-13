class GameSave < ApplicationRecord
  belongs_to :game
  belongs_to :emulator_profile, optional: true

  has_many :sync_events, dependent: :destroy
  has_one_attached :file

  validates :file, presence: true

  scope :latest_first, -> { order(created_at: :desc) }
end
