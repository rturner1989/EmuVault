require "rails_helper"

RSpec.describe GameForm do
  describe "validations" do
    it "is valid with title and system" do
      form = described_class.new(title: "Zelda", system: "snes")

      expect(form).to be_valid
    end

    it "requires title" do
      form = described_class.new(title: "", system: "snes")

      expect(form).not_to be_valid
      expect(form.errors[:title]).to be_present
    end

    it "requires system" do
      form = described_class.new(title: "Zelda", system: "")

      expect(form).not_to be_valid
      expect(form.errors[:system]).to be_present
    end
  end

  describe ".model_name" do
    it "returns Game for form routing" do
      expect(described_class.model_name.name).to eq("Game")
    end
  end

  describe ".from" do
    it "builds a form from an existing game" do
      game = create(:game, title: "Zelda", system: :snes)
      form = described_class.from(game)

      expect(form.title).to eq("Zelda")
      expect(form.system).to eq("snes")
      expect(form.id).to eq(game.id)
      expect(form).to be_persisted
    end
  end

  describe "#persist" do
    it "creates a new game" do
      form = described_class.new(title: "Zelda", system: "snes")
      game = Game.new

      expect(form.persist(game)).to be(true)
      expect(game).to be_persisted
      expect(game.title).to eq("Zelda")
    end

    it "updates an existing game" do
      game = create(:game, title: "Zelda", system: :snes)
      form = described_class.new(title: "Zelda II", system: "snes")

      expect(form.persist(game)).to be(true)
      expect(game.reload.title).to eq("Zelda II")
    end

    it "returns false with invalid data" do
      form = described_class.new(title: "", system: "")
      game = Game.new

      expect(form.persist(game)).to be(false)
      expect(game).not_to be_persisted
    end
  end
end
