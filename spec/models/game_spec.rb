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

  describe "enumerize" do
    it "defines system with game system values" do
      expect(Game.system.values.map(&:to_sym)).to include(:snes, :gba, :psx, :ps2)
    end
  end
end
