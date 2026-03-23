require "rails_helper"

RSpec.describe GameSaveDecorator do
  let(:profile) { create(:emulator_profile, name: "RetroArch", platform: :linux, save_extension: "srm") }
  let(:game) { create(:game, title: "Zelda") }
  let(:game_save) { create(:game_save, game: game, emulator_profile: profile) }
  let(:decorated) { described_class.new(game_save) }

  describe "#emulator_label" do
    it "returns emulator name and platform" do
      expect(decorated.emulator_label).to eq("RetroArch — Linux")
    end

    it "returns unknown when no profile" do
      game_save = create(:game_save, game: game, emulator_profile: nil)
      decorated = described_class.new(game_save)

      expect(decorated.emulator_label).to eq("Unknown emulator")
    end
  end

  describe "#file_size_label" do
    it "formats bytes" do
      allow(game_save.file).to receive(:byte_size).and_return(512)

      expect(decorated.file_size_label).to eq("512 B")
    end

    it "formats kilobytes" do
      allow(game_save.file).to receive(:byte_size).and_return(2048)

      expect(decorated.file_size_label).to eq("2.0 KB")
    end

    it "formats megabytes" do
      allow(game_save.file).to receive(:byte_size).and_return(5_242_880)

      expect(decorated.file_size_label).to eq("5.0 MB")
    end
  end

  describe "#uploaded_at_label" do
    it "formats the timestamp" do
      game_save = create(:game_save, game: game, created_at: Time.zone.parse("2026-03-15 14:30"))
      decorated = described_class.new(game_save)

      expect(decorated.uploaded_at_label).to eq("Mar 15, 2026 at 14:30")
    end
  end

  describe "#download_filename" do
    it "uses the profile extension" do
      expect(decorated.download_filename).to eq("Zelda.srm")
    end

    it "uses a target profile when provided" do
      other_profile = create(:emulator_profile, save_extension: "sav", game_system: :snes)
      expect(decorated.download_filename(other_profile)).to eq("Zelda.sav")
    end

    it "uses custom filename from game_emulator_config" do
      create(:game_emulator_config, game: game, emulator_profile: profile, save_filename: "custom_name")

      expect(decorated.download_filename).to eq("custom_name.srm")
    end

    it "falls back to sav when no profile" do
      game_save = create(:game_save, game: game, emulator_profile: nil)
      decorated = described_class.new(game_save)

      expect(decorated.download_filename).to eq("Zelda.sav")
    end
  end

  describe "#save_path_hint" do
    it "returns nil when profile has no save path" do
      profile.update!(default_save_path: nil)

      expect(decorated.save_path_hint).to be_nil
    end

    it "returns full path when profile has a save path" do
      profile.update!(default_save_path: "~/.config/retroarch/saves")

      expect(decorated.save_path_hint).to eq("~/.config/retroarch/saves/Zelda.srm")
    end
  end
end
