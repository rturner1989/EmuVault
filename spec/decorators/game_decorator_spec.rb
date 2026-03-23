require "rails_helper"

RSpec.describe GameDecorator do
  let(:game) { create(:game, title: "Pokemon - Fire Red (V1.1)", system: :gba) }
  let(:decorated) { described_class.new(game) }

  describe "#system_label" do
    it "returns the human-readable system name" do
      expect(decorated.system_label).to eq("Game Boy Advance")
    end
  end

  describe "#system_badge_color" do
    it "returns green for GBA" do
      expect(decorated.system_badge_color).to eq(:green)
    end

    it "returns purple for SNES" do
      game = create(:game, system: :snes)
      expect(described_class.new(game).system_badge_color).to eq(:purple)
    end

    it "returns cyan for PlayStation" do
      game = create(:game, system: :psx)
      expect(described_class.new(game).system_badge_color).to eq(:cyan)
    end
  end

  describe "#default_save_base_name" do
    it "strips special characters but keeps parentheses" do
      expect(decorated.default_save_base_name).to eq("Pokemon - Fire Red (V1.1)")
    end

    it "strips non-alphanumeric characters" do
      game = create(:game, title: "Zelda: A Link to the Past!")
      decorated = described_class.new(game)

      expect(decorated.default_save_base_name).to eq("Zelda A Link to the Past")
    end
  end

  describe ".decorate" do
    it "decorates a single record" do
      result = described_class.decorate(game)

      expect(result).to be_a(described_class)
    end

    it "decorates a collection" do
      games = create_list(:game, 3)
      result = described_class.decorate(games)

      expect(result).to all(be_a(described_class))
      expect(result.size).to eq(3)
    end
  end
end
