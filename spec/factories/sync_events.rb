FactoryBot.define do
  factory :sync_event do
    game_save
    device
    action { :push }
    status { :success }
    performed_at { Time.current }
  end
end
