FactoryBot.define do
  factory :data_import do
    status { :pending }
    manifest { {} }
    file { Rack::Test::UploadedFile.new(StringIO.new("zip data"), "application/zip", true, original_filename: "backup.zip") }
  end
end
