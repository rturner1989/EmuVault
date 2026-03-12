FactoryBot.define do
  factory :game_save do
    game
    emulator_profile
    slot { 0 }
    checksum { nil }
    saved_at { nil }
  end
end
