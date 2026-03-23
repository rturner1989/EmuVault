require "rails_helper"

RSpec.describe "Settings" do
  let(:user) { sign_in }

  before { user }

  describe "GET /settings" do
    it "renders the settings page" do
      get settings_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /settings" do
    it "updates the theme" do
      patch settings_path, params: { user: { theme: "night" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(user.reload.theme).to eq("night")
    end

    it "updates kuma_url" do
      patch settings_path, params: { user: { kuma_url: "https://kuma.local:3001" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(user.reload.kuma_url).to eq("https://kuma.local:3001")
    end

    it "rejects invalid theme" do
      patch settings_path, params: { user: { theme: "invalid_theme" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.theme).to eq("dracula")
    end

    it "updates scan settings" do
      patch settings_path, params: { user: { scan_enabled: true, scan_interval: "daily" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      user.reload
      expect(user.scan_enabled).to be(true)
      expect(user.scan_interval).to eq("daily")
    end
  end
end
