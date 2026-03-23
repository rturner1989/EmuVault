FactoryBot.define do
  factory :sync_event do
    game_save
    action { :push }
    status { :success }
    performed_at { Time.current }
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0" }
  end
end
