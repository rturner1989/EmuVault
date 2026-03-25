require "rails_helper"

RSpec.describe DataImport do
  describe "enum" do
    it "defines status with expected values" do
      expect(described_class.statuses.keys).to eq(
        %w[pending analyzing conflicts_pending importing complete failed]
      )
    end
  end

  describe "file size limit" do
    it "rejects files over 500MB" do
      import = build(:data_import)
      large_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("x" * 1024),
        filename: "large.zip"
      )

      allow(large_blob).to receive(:byte_size).and_return(501.megabytes)
      import.file.attach(large_blob)

      expect(import).not_to be_valid
      expect(import.errors[:file].first).to include("too large")
    end
  end
end
