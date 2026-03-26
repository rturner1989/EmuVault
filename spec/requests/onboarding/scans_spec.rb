require "rails_helper"

RSpec.describe "Onboarding::Scans" do
  let(:user) { sign_in(create(:user, setup_completed: false)) }

  before { user }

  describe "POST /onboarding/scan" do
    it "enqueues scan job" do
      allow(GameScanJob).to receive(:perform_later).with("auto_all")

      post onboarding_scan_path,
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(GameScanJob).to have_received(:perform_later).with("auto_all")
    end

    it "shows scanning indicator via turbo stream" do
      allow(GameScanJob).to receive(:perform_later).with("auto_all")

      post onboarding_scan_path,
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("scan-progress")
      expect(response.body).to include("Scanning your library")
    end

    it "redirects to root when setup is already complete" do
      user.update!(setup_completed: true)

      post onboarding_scan_path

      expect(response).to redirect_to(root_path)
    end
  end
end
