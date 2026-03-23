FactoryBot.define do
  factory :web_push_subscription do
    user
    sequence(:endpoint) { |n| "https://push.example.com/sub/#{n}" }
    p256dh { SecureRandom.base64(65) }
    auth { SecureRandom.base64(16) }
  end
end
