require "rails_helper"

RSpec.describe GameSave do
  subject(:game_save) { build(:game_save) }

  describe "associations" do
    it { is_expected.to belong_to(:game) }
    it { is_expected.to belong_to(:emulator_profile).optional }
    it { is_expected.to have_many(:sync_events).dependent(:destroy) }
    it { is_expected.to have_one_attached(:file) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:file) }
  end

  describe "file size limit" do
    it "rejects files over 100MB" do
      large_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("x" * 1024),
        filename: "large.srm"
      )

      allow(large_blob).to receive(:byte_size).and_return(101.megabytes)
      game_save.file.attach(large_blob)

      expect(game_save).not_to be_valid
      expect(game_save.errors[:file].first).to include("too large")
    end
  end

  describe "scopes" do
    describe ".latest_first" do
      it "orders by created_at descending" do
        old_save = create(:game_save, created_at: 1.day.ago)
        new_save = create(:game_save, created_at: 1.hour.ago)

        expect(described_class.latest_first).to eq([ new_save, old_save ])
      end
    end
  end
end
