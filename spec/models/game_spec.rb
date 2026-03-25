require "rails_helper"

RSpec.describe Game do
  subject(:game) { build(:game) }

  describe "associations" do
    it { is_expected.to have_many(:game_saves).dependent(:destroy) }
    it { is_expected.to have_many(:game_emulator_configs).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:system) }
  end

  describe "enum" do
    it "defines system with game system values" do
      expect(described_class.systems.keys).to include("snes", "gba", "psx", "ps2")
    end
  end

  describe "#system_label" do
    it "returns the human-readable system name" do
      game = create(:game, system: :gba)

      expect(game.system_label).to eq("Game Boy Advance")
    end
  end

  describe "#system_badge_color" do
    it "returns green for GBA" do
      game = create(:game, system: :gba)

      expect(game.system_badge_color).to eq(:green)
    end

    it "returns purple for SNES" do
      game = create(:game, system: :snes)

      expect(game.system_badge_color).to eq(:purple)
    end

    it "returns cyan for PlayStation" do
      game = create(:game, system: :psx)

      expect(game.system_badge_color).to eq(:cyan)
    end
  end

  describe "#default_save_base_name" do
    it "strips special characters but keeps parentheses" do
      game = create(:game, title: "Pokemon - Fire Red (V1.1)", system: :gba)

      expect(game.default_save_base_name).to eq("Pokemon - Fire Red (V1.1)")
    end

    it "strips non-alphanumeric characters" do
      game = create(:game, title: "Zelda: A Link to the Past!")

      expect(game.default_save_base_name).to eq("Zelda A Link to the Past")
    end
  end
end
