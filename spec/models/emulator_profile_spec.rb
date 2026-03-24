require "rails_helper"

RSpec.describe EmulatorProfile do
  subject(:profile) { build(:emulator_profile) }

  describe "associations" do
    it { is_expected.to have_many(:game_saves).dependent(:nullify) }
    it { is_expected.to have_many(:game_emulator_configs).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:platform) }
    it { is_expected.to validate_presence_of(:game_system) }
    it { is_expected.to validate_presence_of(:save_extension) }

    it "enforces uniqueness of name scoped to platform and game_system" do
      create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :snes)
      duplicate = build(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :snes)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end

    it "allows same name with different platform" do
      create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :snes)
      different_platform = build(:emulator_profile, name: "RetroArch", platform: :windows, game_system: :snes)

      expect(different_platform).to be_valid
    end

    it "allows same name with different game_system" do
      create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :snes)
      different_system = build(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba)

      expect(different_system).to be_valid
    end
  end

  describe "scopes" do
    let!(:selected_gba) { create(:emulator_profile, game_system: :gba, user_selected: true) }
    let!(:unselected_gba) { create(:emulator_profile, game_system: :gba, user_selected: false) }

    before { create(:emulator_profile, game_system: :snes, user_selected: true) }

    describe ".for_system" do
      it "returns profiles for the given system" do
        expect(described_class.for_system(:gba)).to contain_exactly(unselected_gba, selected_gba)
      end
    end

    describe ".selected_for_system" do
      it "returns only selected profiles for the given system" do
        expect(described_class.selected_for_system(:gba)).to contain_exactly(selected_gba)
      end
    end
  end

  describe "#deletable?" do
    it "returns true for custom profiles" do
      profile = build(:emulator_profile, is_default: false)
      expect(profile).to be_deletable
    end

    it "returns false for default profiles" do
      profile = build(:emulator_profile, :default_profile)
      expect(profile).not_to be_deletable
    end
  end

  describe "#in_use?" do
    it "returns false when no games exist for the system" do
      profile = create(:emulator_profile, game_system: :snes)
      expect(profile).not_to be_in_use
    end

    it "returns true when games exist for the system" do
      profile = create(:emulator_profile, game_system: :snes)
      create(:game, system: :snes)

      expect(profile).to be_in_use
    end
  end
end
