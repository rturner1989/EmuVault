require "rails_helper"

RSpec.describe "ScanPaths" do
  let(:user) { sign_in }

  before { user }

  describe "POST /scan_paths" do
    it "creates a scan path via turbo frame" do
      post scan_paths_path, params: {
        scan_path: { path: "/home/user/roms", game_system: "snes" }
      }, headers: { "Turbo-Frame" => "scan_paths", "Accept" => "text/vnd.turbo-stream.html" }

      expect(ScanPath.count).to eq(1)
      expect(ScanPath.last.path).to eq("/home/user/roms")
    end

    it "redirects on invalid params" do
      post scan_paths_path, params: {
        scan_path: { path: "", game_system: "" }
      }, headers: { "Turbo-Frame" => "scan_paths" }

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /scan_paths/:id" do
    it "destroys the scan path" do
      scan_path = create(:scan_path)

      delete scan_path_path(scan_path),
        headers: { "Turbo-Frame" => "scan_paths", "Accept" => "text/vnd.turbo-stream.html" }

      expect(ScanPath.exists?(scan_path.id)).to be(false)
    end
  end
end
