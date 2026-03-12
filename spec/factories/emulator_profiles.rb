FactoryBot.define do
  factory :emulator_profile do
    sequence(:name) { |n| "RetroArch #{n}" }
    platform { :linux }
    save_extension { "srm" }
    default_save_path { "~/.config/retroarch/saves" }
  end
end
