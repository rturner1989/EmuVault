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
  DEVICE_BADGE_COLORS = {
    phone: :orange,
    tablet: :yellow,
    desktop: :purple
  }.freeze

  enum :action, { push: "push", pull: "pull" }
  enum :status, { success: "success", failed: "failed" }

  belongs_to :game_save

  validates :action, presence: true
  validates :status, presence: true
  validates :performed_at, presence: true

  scope :recent, -> { order(performed_at: :desc) }
  scope :oldest_first, -> { order(performed_at: :asc) }
  scope :for_game, ->(game_id) { joins(game_save: :game).where(games: { id: game_id }) }

  def device_type
    ua = user_agent.to_s
    if ua.match?(/iPad|Android.*Tablet|Kindle/i)
      :tablet
    elsif ua.match?(/Mobile|Android|iPhone|iPod/i)
      :phone
    else
      :desktop
    end
  end

  def device_label
    I18n.t("models.device.#{device_type}")
  end

  def device_badge_color
    DEVICE_BADGE_COLORS[device_type]
  end

  def action_label
    I18n.t("models.sync_action.#{action}")
  end

  def action_icon
    push? ? "fa-arrow-up" : "fa-arrow-down"
  end

  def action_badge_color
    push? ? :green : :cyan
  end

  def performed_at_label
    performed_at.strftime("%b %-d, %Y at %H:%M")
  end

  def game_title
    game_save.game.title
  end

  def game_id
    game_save.game_id
  end
end
