FactoryBot.define do
  factory :game_save do
    game
    emulator_profile
    checksum { SecureRandom.hex(32) }
    saved_at { Time.current }
    file { Rack::Test::UploadedFile.new(StringIO.new("save data"), "application/octet-stream", true, original_filename: "save.srm") }
  end
end
