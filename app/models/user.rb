# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  api_token        :string
#  email_address    :string           not null
#  last_scan_result :jsonb
#  last_scanned_at  :datetime
#  password_digest  :string           not null
#  scan_enabled     :boolean          default(FALSE), not null
#  scan_interval    :string           default("hourly"), not null
#  setup_completed  :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_api_token      (api_token) UNIQUE
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord
  extend Enumerize

  enumerize :scan_interval, in: %i[hourly every_6_hours daily], default: :hourly

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :web_push_subscriptions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  before_create :generate_api_token

  def regenerate_api_token!
    update!(api_token: SecureRandom.hex(32))
  end

  private

  def generate_api_token
    self.api_token ||= SecureRandom.hex(32)
  end
end
