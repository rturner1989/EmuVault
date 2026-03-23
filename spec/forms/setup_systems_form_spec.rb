require "rails_helper"

RSpec.describe SetupSystemsForm do
  describe "validations" do
    it "requires at least one system" do
      form = described_class.new(system_keys: [])

      expect(form).not_to be_valid
      expect(form.errors[:base]).to include("Please select at least one system")
    end

    it "is valid with systems selected" do
      form = described_class.new(system_keys: ["snes", "gba"])

      expect(form).to be_valid
    end

    it "strips blank entries" do
      form = described_class.new(system_keys: ["", "snes", ""])

      expect(form).to be_valid
      expect(form.system_keys).to eq(["snes"])
    end
  end

  describe "#save" do
    it "deselects profiles for unchecked systems" do
      snes_profile = create(:emulator_profile, :default_profile, game_system: :snes, user_selected: true)
      gba_profile = create(:emulator_profile, :default_profile, game_system: :gba, user_selected: true)

      form = described_class.new(system_keys: ["snes"])
      form.save

      expect(snes_profile.reload.user_selected).to be(true)
      expect(gba_profile.reload.user_selected).to be(false)
    end

    it "returns false when invalid" do
      form = described_class.new(system_keys: [])

      expect(form.save).to be(false)
    end
  end
end
