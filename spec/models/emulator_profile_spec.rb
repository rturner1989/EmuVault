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

    describe ".user_selected" do
      it "returns only user-selected profiles" do
        expect(described_class.user_selected).to include(selected_gba)
        expect(described_class.user_selected).not_to include(unselected_gba)
      end
    end

    describe ".defaults" do
      let!(:default_profile) { create(:emulator_profile, :default_profile, game_system: :nes) }

      it "returns only default profiles" do
        expect(described_class.defaults).to include(default_profile)
        expect(described_class.defaults).not_to include(selected_gba)
      end
    end

    describe ".defaults_for_system" do
      let!(:default_gba) { create(:emulator_profile, :default_profile, game_system: :gba) }
      let!(:default_snes) { create(:emulator_profile, :default_profile, game_system: :snes, name: "Snes9x") }

      it "returns only default profiles for the given system" do
        expect(described_class.defaults_for_system(:gba)).to include(default_gba)
        expect(described_class.defaults_for_system(:gba)).not_to include(default_snes)
      end
    end
  end

  describe ".selected_game_systems" do
    it "returns distinct game systems for selected profiles" do
      create(:emulator_profile, game_system: :gba, user_selected: true, name: "P1")
      create(:emulator_profile, game_system: :gba, user_selected: true, name: "P2", platform: :windows)
      create(:emulator_profile, game_system: :snes, user_selected: true, name: "P3")
      create(:emulator_profile, game_system: :nes, user_selected: false, name: "P4")

      expect(described_class.selected_game_systems).to contain_exactly(:gba, :snes)
    end
  end

  describe ".default_game_systems" do
    it "returns distinct game systems for default profiles" do
      create(:emulator_profile, :default_profile, game_system: :gba, name: "D1")
      create(:emulator_profile, :default_profile, game_system: :snes, name: "D2")
      create(:emulator_profile, game_system: :nes, is_default: false, name: "D3")

      expect(described_class.default_game_systems).to contain_exactly(:gba, :snes)
    end
  end

  describe ".selected_by_system" do
    it "groups selected profiles by system symbol" do
      gba = create(:emulator_profile, game_system: :gba, user_selected: true, name: "RA")
      snes = create(:emulator_profile, game_system: :snes, user_selected: true, name: "S9x")
      create(:emulator_profile, game_system: :nes, user_selected: false, name: "Other")

      result = described_class.selected_by_system

      expect(result.keys).to contain_exactly(:gba, :snes)
      expect(result[:gba]).to include(gba)
      expect(result[:snes]).to include(snes)
    end
  end

  describe ".selected_default_ids_for_system" do
    it "returns IDs of selected default profiles for a system" do
      selected_default = create(:emulator_profile, :default_profile, game_system: :gba, user_selected: true)
      create(:emulator_profile, :default_profile, game_system: :gba, user_selected: false, name: "Other")
      create(:emulator_profile, game_system: :gba, user_selected: true, is_default: false, name: "Custom")

      result = described_class.selected_default_ids_for_system(:gba)

      expect(result).to eq(Set[selected_default.id])
    end
  end

  describe ".update_selections_for_system" do
    let!(:profile_a) { create(:emulator_profile, :default_profile, game_system: :gba, user_selected: true) }
    let!(:profile_b) { create(:emulator_profile, :default_profile, game_system: :gba, user_selected: true, name: "Other") }

    it "deselects all defaults then selects specified ones" do
      described_class.update_selections_for_system(:gba, selected_ids: [ profile_b.id ])

      expect(profile_a.reload.user_selected).to be false
      expect(profile_b.reload.user_selected).to be true
    end

    it "deselects all when no IDs provided" do
      described_class.update_selections_for_system(:gba)

      expect(profile_a.reload.user_selected).to be false
      expect(profile_b.reload.user_selected).to be false
    end
  end

  describe ".visible_system_options" do
    it "returns combined selected and default systems as options" do
      create(:emulator_profile, game_system: :gba, user_selected: true, name: "P1")
      create(:emulator_profile, :default_profile, game_system: :snes, name: "P2")

      result = described_class.visible_system_options

      values = result.map { |option| option[:value] }
      expect(values).to include("gba", "snes")
      expect(result.first).to have_key(:text)
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
