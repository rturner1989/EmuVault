FactoryBot.define do
  factory :game_emulator_config do
    game
    emulator_profile
    save_filename { "game.srm" }
  end
end
