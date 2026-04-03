# == Schema Information
#
# Table name: users
#
#  id                    :bigint           not null, primary key
#  api_token             :string
#  games_view_preference :string           default("card"), not null
#  kuma_url              :string
#  last_scan_result      :jsonb
#  last_scanned_at       :datetime
#  password_digest       :string           not null
#  scan_enabled          :boolean          default(FALSE), not null
#  scan_interval         :string           default("hourly"), not null
#  setup_completed       :boolean          default(FALSE), not null
#  theme                 :string           default("dracula"), not null
#  username              :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  current_game_id       :bigint
#
# Indexes
#
#  index_users_on_api_token        (api_token) UNIQUE
#  index_users_on_current_game_id  (current_game_id)
#  index_users_on_username         (username) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (current_game_id => games.id) ON DELETE => nullify
#
class User < ApplicationRecord
  THEMES = {
    "Dark" => %w[dracula night dark business luxury coffee dim sunset],
    "Light" => %w[light cupcake emerald corporate retro cyberpunk valentine
                  garden aqua pastel wireframe nord lemonade caramellatte]
  }.freeze

  ALL_THEMES = THEMES.values.flatten.freeze

  GAMES_VIEW_PREFERENCES = %w[card list].freeze

  enum :scan_interval, { hourly: "hourly", every_6_hours: "every_6_hours", daily: "daily" }

  def self.scan_interval_options
    { hourly: "hourly", every_6_hours: "every_6_hours", daily: "daily" }.map do |key, value|
      [ I18n.t("models.scan_interval.#{key}"), value ]
    end
  end

  validates :theme, inclusion: { in: ALL_THEMES }
  validates :games_view_preference, inclusion: { in: GAMES_VIEW_PREFERENCES }
  validates :kuma_url, format: { with: /\Ahttps?:\/\/\S+\z/i, message: :invalid_url }, allow_blank: true

  has_secure_password

  belongs_to :current_game, class_name: "Game", optional: true
  has_many :sessions, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :web_push_subscriptions, dependent: :destroy

  normalizes :username, with: ->(e) { e.strip.downcase }

  before_create :generate_api_token

  def unread_notifications
    notifications.where(read_at: nil)
  end

  def unread_notifications_count
    unread_notifications.count
  end

  def mark_all_notifications_read!
    unread_notifications.update_all(read_at: Time.current)
  end

  def scan_due?
    return true if last_scanned_at.nil?

    interval = case scan_interval.to_s
    when "every_6_hours" then 6.hours
    when "daily"         then 1.day
    else                      1.hour
    end

    last_scanned_at < interval.ago
  end

  def regenerate_api_token!
    update!(api_token: SecureRandom.hex(32))
  end

  private def generate_api_token
    self.api_token ||= SecureRandom.hex(32)
  end
end
