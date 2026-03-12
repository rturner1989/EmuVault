class SyncEvent < ApplicationRecord
  extend Enumerize

  enumerize :action, in: %i[push pull], predicates: true
  enumerize :status, in: %i[success failed conflict], predicates: true

  belongs_to :game_save
  belongs_to :device, optional: true

  validates :action, presence: true
  validates :status, presence: true
  validates :performed_at, presence: true
end
