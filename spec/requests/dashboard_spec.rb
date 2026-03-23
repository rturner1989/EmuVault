require "rails_helper"

RSpec.describe "Dashboard" do
  describe "GET /" do
    it "requires authentication" do
      create(:user)

      get root_path

      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to registration when no users exist" do
      get root_path

      expect(response).to redirect_to(new_registration_path)
    end

    it "renders the dashboard" do
      sign_in

      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "displays game stats" do
      sign_in
      create_list(:game, 3)

      get root_path

      expect(response.body).to include("3")
    end
  end
end
