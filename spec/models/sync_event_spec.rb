require "rails_helper"

RSpec.describe SyncEvent do
  subject(:sync_event) { build(:sync_event) }

  describe "associations" do
    it { is_expected.to belong_to(:game_save) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:performed_at) }
  end

  describe "enumerize" do
    it "defines action with push and pull" do
      expect(described_class.action.values.map(&:to_sym)).to eq(%i[push pull])
    end

    it "defines status with success and failed" do
      expect(described_class.status.values.map(&:to_sym)).to eq(%i[success failed])
    end
  end

  describe "scopes" do
    describe ".recent" do
      it "orders by performed_at descending" do
        old_event = create(:sync_event, performed_at: 1.day.ago)
        new_event = create(:sync_event, performed_at: 1.hour.ago)

        expect(described_class.recent).to eq([ new_event, old_event ])
      end
    end
  end
end
