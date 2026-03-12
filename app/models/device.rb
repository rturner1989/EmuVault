class Device < ApplicationRecord
  extend Enumerize

  enumerize :device_type, in: %i[pc phone tablet], predicates: true

  has_many :sync_events, dependent: :destroy

  validates :name, presence: true
  validates :device_type, presence: true
  validates :identifier, uniqueness: true, allow_nil: true
end
