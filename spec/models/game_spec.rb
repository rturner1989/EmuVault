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

  describe ".without_saves" do
    it "returns games that have no saves" do
      game_with_save = create(:game, title: "Zelda", system: :gba)
      game_without_save = create(:game, title: "Mario", system: :gba)
      create(:game_save, game: game_with_save)

      expect(described_class.without_saves).to contain_exactly(game_without_save)
    end

    it "returns all games when none have saves" do
      games = create_list(:game, 3, system: :gba)

      expect(described_class.without_saves.count).to eq(3)
    end

    it "returns empty when all games have saves" do
      game = create(:game, system: :gba)
      create(:game_save, game: game)

      expect(described_class.without_saves).to be_empty
    end
  end

  describe ".storage_used_bytes" do
    it "returns total byte size of game save attachments" do
      game = create(:game, system: :gba)
      save_record = create(:game_save, game: game)
      save_record.file.attach(
        io: StringIO.new("x" * 1024),
        filename: "test.sav",
        content_type: "application/octet-stream"
      )

      expect(described_class.storage_used_bytes).to eq(1024)
    end

    it "returns zero when no saves exist" do
      expect(described_class.storage_used_bytes).to eq(0)
    end
  end

  describe ".top_by_sync_events" do
    it "returns games ordered by sync event count" do
      game_a = create(:game, title: "Zelda", system: :gba)
      game_b = create(:game, title: "Mario", system: :gba)
      save_a = create(:game_save, game: game_a)
      save_b = create(:game_save, game: game_b)
      create_list(:sync_event, 3, game_save: save_a)
      create_list(:sync_event, 1, game_save: save_b)

      result = described_class.top_by_sync_events(limit: 2)

      expect(result.first[:title]).to eq("Zelda")
      expect(result.first[:count]).to eq(3)
      expect(result.second[:title]).to eq("Mario")
    end

    it "respects the limit" do
      3.times do |i|
        game = create(:game, title: "Game #{i}", system: :gba)
        save_record = create(:game_save, game: game)
        create(:sync_event, game_save: save_record)
      end

      expect(described_class.top_by_sync_events(limit: 2).size).to eq(2)
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
