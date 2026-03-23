require "rails_helper"

RSpec.describe "Sessions" do
  let!(:user) { create(:user, username: "admin", password: "password123") }

  describe "GET /session/new" do
    it "renders the login page" do
      get new_session_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects to registration when no users exist" do
      User.destroy_all

      get new_session_path

      expect(response).to redirect_to(new_registration_path)
    end
  end

  describe "POST /session" do
    it "signs in with valid credentials and redirects" do
      post session_path, params: { session: { username: "admin", password: "password123" } }

      expect(response).to redirect_to(root_path)
      expect(Session.count).to eq(1)
    end

    it "rejects invalid credentials" do
      post session_path, params: { session: { username: "admin", password: "wrong" } }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to eq("Try another username or password.")
    end

    it "rejects blank credentials" do
      post session_path, params: { session: { username: "", password: "" } }

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "DELETE /session" do
    it "signs out the user" do
      sign_in(user)
      session_count_before = Session.count

      delete session_path

      expect(response).to redirect_to(new_session_path)
      expect(Session.count).to eq(session_count_before - 1)
    end
  end
end
