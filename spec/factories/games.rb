FactoryBot.define do
  factory :game do
    sequence(:title) { |n| "Game #{n}" }
    system { :snes }
    rom_hash { nil }
  end
end
