require "rails_helper"

RSpec.describe Layouts::AppShellComponent, type: :component do
  before do
    user = create(:user)
    Current.session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
  end

  describe "#stimulus_controllers" do
    it "includes notifications and quick-sync by default" do
      component = described_class.new(current_path: "/")

      expect(component.stimulus_controllers).to eq("notifications quick-sync")
    end

    it "includes onboarding when onboarding is true" do
      component = described_class.new(current_path: "/", onboarding: true)

      expect(component.stimulus_controllers).to eq("notifications quick-sync onboarding")
    end

    it "excludes onboarding when onboarding is false" do
      component = described_class.new(current_path: "/", onboarding: false)

      expect(component.stimulus_controllers).not_to include("onboarding")
    end
  end
end
