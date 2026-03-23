require "rails_helper"

RSpec.describe WebPushSubscription do
  subject(:subscription) { build(:web_push_subscription) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:endpoint) }
    it { is_expected.to validate_presence_of(:p256dh) }
    it { is_expected.to validate_presence_of(:auth) }

    it "enforces uniqueness of endpoint" do
      create(:web_push_subscription, endpoint: "https://push.example.com/sub/1")
      duplicate = build(:web_push_subscription, endpoint: "https://push.example.com/sub/1")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:endpoint]).to be_present
    end
  end
end
