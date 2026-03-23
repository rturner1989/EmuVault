FactoryBot.define do
  factory :scan_path do
    path { "/home/user/roms" }
    game_system { :snes }
    auto_scan { false }
  end
end
