class SyncEvent < ApplicationRecord
  extend Enumerize

  enumerize :action, in: %i[push pull], predicates: true
  enumerize :status, in: %i[success failed], predicates: true

  belongs_to :game_save

  validates :action, presence: true
  validates :status, presence: true
  validates :performed_at, presence: true

  scope :recent, -> { order(performed_at: :desc) }
end
