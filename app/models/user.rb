class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

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
