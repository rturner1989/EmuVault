require "rails_helper"

RSpec.describe "Games::Scans::Dismissals" do
  let(:user) { sign_in }

  before { user }

  describe "POST /game_scan/dismissal" do
    it "marks the scan result as reviewed" do
      user.update!(last_scan_result: {
        "status" => "pending_review",
        "found" => [ { "title" => "Zelda", "game_system" => "gba" } ]
      })

      post game_scan_dismissal_path

      expect(user.reload.last_scan_result["status"]).to eq("reviewed")
      expect(response).to redirect_to(games_path)
    end

    it "handles missing scan result gracefully" do
      user.update!(last_scan_result: nil)

      post game_scan_dismissal_path

      expect(response).to redirect_to(games_path)
    end
  end
end
