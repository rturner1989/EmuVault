require "rails_helper"

RSpec.describe "Onboarding::Scans" do
  let(:user) { sign_in(create(:user, setup_completed: false)) }

  before { user }

  describe "POST /onboarding/scan" do
    it "runs auto_all scan and redirects to onboarding games" do
      allow(GameScanJob).to receive(:perform_now).with("auto_all").and_return({ "added" => 0 })

      post onboarding_scan_path

      expect(GameScanJob).to have_received(:perform_now).with("auto_all")
      expect(response).to redirect_to(onboarding_games_path)
    end

    it "reports the number of games imported" do
      allow(GameScanJob).to receive(:perform_now).with("auto_all").and_return({ "added" => 3 })

      post onboarding_scan_path

      expect(flash[:notice]).to include("3")
    end

    it "redirects to root when setup is already complete" do
      user.update!(setup_completed: true)

      post onboarding_scan_path

      expect(response).to redirect_to(root_path)
    end
  end
end
