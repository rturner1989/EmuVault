FactoryBot.define do
  factory :device do
    sequence(:name) { |n| "Device #{n}" }
    device_type { :pc }
    identifier { nil }
    last_seen_at { nil }
  end
end
