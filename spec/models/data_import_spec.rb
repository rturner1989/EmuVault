require "rails_helper"
require "zip"

RSpec.describe DataImport do
  describe "enum" do
    it "defines status with expected values" do
      expect(described_class.statuses.keys).to eq(
        %w[pending analyzing conflicts_pending importing complete failed]
      )
    end
  end

  describe ".analyze_zip" do
    it "returns manifest and empty conflicts for a valid zip" do
      zip_data = build_export_zip([ { "title" => "Zelda", "system" => "gba" } ])
      uploaded = fake_upload(zip_data)

      manifest, conflicts = described_class.analyze_zip(uploaded)

      expect(manifest["games"].size).to eq(1)
      expect(manifest["games"].first["title"]).to eq("Zelda")
      expect(conflicts).to be_empty
    end

    it "detects conflicts with existing games" do
      create(:game, title: "Zelda", system: :gba)
      zip_data = build_export_zip([ { "title" => "Zelda", "system" => "gba" } ])
      uploaded = fake_upload(zip_data)

      _manifest, conflicts = described_class.analyze_zip(uploaded)

      expect(conflicts.size).to eq(1)
      expect(conflicts.first["title"]).to eq("Zelda")
    end

    it "returns nil manifest when manifest.json is missing" do
      zip_data = build_export_zip(nil)
      uploaded = fake_upload(zip_data)

      manifest, conflicts = described_class.analyze_zip(uploaded)

      expect(manifest).to be_nil
      expect(conflicts).to be_empty
    end

    it "returns nil manifest for a corrupted zip" do
      uploaded = fake_upload("not a zip")

      manifest, conflicts = described_class.analyze_zip(uploaded)

      expect(manifest).to be_nil
      expect(conflicts).to be_empty
    end

    private

    def build_export_zip(games)
      buffer = Zip::OutputStream.write_buffer do |zip|
        if games
          zip.put_next_entry("manifest.json")
          zip.write({ "games" => games }.to_json)
        end
      end
      buffer.string
    end

    def fake_upload(content)
      tempfile = Tempfile.new([ "test", ".zip" ])
      tempfile.binmode
      tempfile.write(content)
      tempfile.rewind

      uploaded = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: "export.zip",
        type: "application/zip"
      )
      uploaded
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
