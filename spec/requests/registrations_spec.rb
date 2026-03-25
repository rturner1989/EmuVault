require "rails_helper"

RSpec.describe "Registrations" do
  describe "GET /registration/new" do
    it "renders registration form when no users exist" do
      get new_registration_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects to root when a user already exists" do
      create(:user)

      get new_registration_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /registration" do
    it "creates a new user and redirects to setup" do
      post registration_path, params: {
        user: { username: "admin", password: "password123", password_confirmation: "password123" }
      }

      expect(User.count).to eq(1)
      expect(response).to redirect_to(root_path)
    end

    it "re-renders form with invalid params" do
      post registration_path, params: {
        user: { username: "", password: "short", password_confirmation: "mismatch" }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "blocks registration when a user already exists" do
      create(:user)

      post registration_path, params: {
        user: { username: "hacker", password: "password123", password_confirmation: "password123" }
      }

      expect(response).to redirect_to(root_path)
      expect(User.count).to eq(1)
    end
  end
end
