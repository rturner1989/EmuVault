FactoryBot.define do
  factory :emulator_profile do
    sequence(:name) { |n| "RetroArch #{n}" }
    platform { :linux }
    game_system { :snes }
    save_extension { "srm" }
    default_save_path { "~/.config/retroarch/saves" }
    is_default { false }
    user_selected { true }

    trait :default_profile do
      is_default { true }
    end

    trait :unselected do
      user_selected { false }
    end
  end
end
