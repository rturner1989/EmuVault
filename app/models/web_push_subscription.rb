# == Schema Information
#
# Table name: web_push_subscriptions
#
#  id         :bigint           not null, primary key
#  auth       :string           not null
#  endpoint   :string           not null
#  p256dh     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_web_push_subscriptions_on_endpoint  (endpoint) UNIQUE
#  index_web_push_subscriptions_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class WebPushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh, presence: true
  validates :auth, presence: true
end
