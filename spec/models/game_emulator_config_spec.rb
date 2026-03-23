require "rails_helper"

RSpec.describe GameEmulatorConfig do
  subject(:config) { build(:game_emulator_config) }

  describe "associations" do
    it { is_expected.to belong_to(:game) }
    it { is_expected.to belong_to(:emulator_profile) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:save_filename) }

    it "enforces uniqueness of emulator_profile scoped to game" do
      existing = create(:game_emulator_config)
      duplicate = build(:game_emulator_config,
        game: existing.game,
        emulator_profile: existing.emulator_profile)

      expect(duplicate).not_to be_valid
    end

    it "allows same profile for different games" do
      profile = create(:emulator_profile)
      create(:game_emulator_config, emulator_profile: profile)
      different_game = build(:game_emulator_config, emulator_profile: profile)

      expect(different_game).to be_valid
    end
  end
end
