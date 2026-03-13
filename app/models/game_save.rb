# == Schema Information
#
# Table name: game_saves
#
#  id                  :bigint           not null, primary key
#  checksum            :string
#  saved_at            :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  emulator_profile_id :bigint
#  game_id             :bigint           not null
#
# Indexes
#
#  index_game_saves_on_emulator_profile_id  (emulator_profile_id)
#  index_game_saves_on_game_id              (game_id)
#
# Foreign Keys
#
#  fk_rails_...  (emulator_profile_id => emulator_profiles.id)
#  fk_rails_...  (game_id => games.id)
#
class GameSave < ApplicationRecord
  belongs_to :game
  belongs_to :emulator_profile, optional: true

  has_many :sync_events, dependent: :destroy
  has_one_attached :file

  validates :file, presence: true

  scope :latest_first, -> { order(created_at: :desc) }

  after_create_commit :notify_new_save, if: -> { Current.user.present? }

  private

  def notify_new_save
    user = Current.user
    NewSaveNotifier.with(game_save: self).deliver(user)
    count = user.notifications.where(read_at: nil).count
    Turbo::StreamsChannel.broadcast_replace_later_to(
      "notifications_#{user.id}",
      targets: "[data-notification-badge]",
      partial: "shared/notification_badge",
      locals: { count: count }
    )
  end
end
