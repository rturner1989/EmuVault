require "rails_helper"

RSpec.describe ScanPath do
  subject(:scan_path) { build(:scan_path) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_presence_of(:game_system) }
  end

  describe "scopes" do
    describe ".for_auto_scan" do
      it "returns only paths with auto_scan enabled" do
        auto = create(:scan_path, auto_scan: true)
        create(:scan_path, auto_scan: false)

        expect(described_class.for_auto_scan).to contain_exactly(auto)
      end
    end
  end
end
