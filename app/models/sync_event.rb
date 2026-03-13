# == Schema Information
#
# Table name: sync_events
#
#  id           :bigint           not null, primary key
#  action       :string           not null
#  ip_address   :string
#  performed_at :datetime         not null
#  status       :string           not null
#  user_agent   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  game_save_id :bigint           not null
#
# Indexes
#
#  index_sync_events_on_game_save_id  (game_save_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_save_id => game_saves.id)
#
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
