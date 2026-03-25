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

  describe "#emulator_label" do
    it "returns emulator name and platform" do
      profile = create(:emulator_profile, name: "RetroArch", platform: :linux)
      game_save = create(:game_save, emulator_profile: profile)

      expect(game_save.emulator_label).to eq("RetroArch — Linux")
    end

    it "returns unknown when no profile" do
      game_save = create(:game_save, emulator_profile: nil)

      expect(game_save.emulator_label).to eq("Unknown emulator")
    end
  end

  describe "#file_size_label" do
    it "formats bytes" do
      game_save = create(:game_save)
      allow(game_save.file).to receive(:byte_size).and_return(512)

      expect(game_save.file_size_label).to eq("512 B")
    end

    it "formats kilobytes" do
      game_save = create(:game_save)
      allow(game_save.file).to receive(:byte_size).and_return(2048)

      expect(game_save.file_size_label).to eq("2.0 KB")
    end

    it "formats megabytes" do
      game_save = create(:game_save)
      allow(game_save.file).to receive(:byte_size).and_return(5_242_880)

      expect(game_save.file_size_label).to eq("5.0 MB")
    end
  end

  describe "#uploaded_at_label" do
    it "formats the timestamp" do
      game_save = create(:game_save, created_at: Time.zone.parse("2026-03-15 14:30"))

      expect(game_save.uploaded_at_label).to eq("Mar 15, 2026 at 14:30")
    end
  end

  describe "#download_filename" do
    let(:profile) { create(:emulator_profile, name: "RetroArch", platform: :linux, save_extension: "srm") }
    let(:game) { create(:game, title: "Zelda") }

    it "uses the profile extension" do
      game_save = create(:game_save, game: game, emulator_profile: profile)

      expect(game_save.download_filename).to eq("Zelda.srm")
    end

    it "uses a target profile when provided" do
      game_save = create(:game_save, game: game, emulator_profile: profile)
      other_profile = create(:emulator_profile, save_extension: "sav", game_system: :snes)

      expect(game_save.download_filename(other_profile)).to eq("Zelda.sav")
    end

    it "uses custom filename from game_emulator_config" do
      game_save = create(:game_save, game: game, emulator_profile: profile)
      create(:game_emulator_config, game: game, emulator_profile: profile, save_filename: "custom_name")

      expect(game_save.download_filename).to eq("custom_name.srm")
    end

    it "falls back to sav when no profile" do
      game_save = create(:game_save, game: game, emulator_profile: nil)

      expect(game_save.download_filename).to eq("Zelda.sav")
    end
  end

  describe "#save_path_hint" do
    let(:profile) { create(:emulator_profile, name: "RetroArch", platform: :linux, save_extension: "srm") }
    let(:game) { create(:game, title: "Zelda") }

    it "returns nil when profile has no save path" do
      game_save = create(:game_save, game: game, emulator_profile: profile)
      profile.update!(default_save_path: nil)

      expect(game_save.save_path_hint).to be_nil
    end

    it "returns full path when profile has a save path" do
      game_save = create(:game_save, game: game, emulator_profile: profile)
      profile.update!(default_save_path: "~/.config/retroarch/saves")

      expect(game_save.save_path_hint).to eq("~/.config/retroarch/saves/Zelda.srm")
    end
  end
end
