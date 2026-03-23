require "rails_helper"

RSpec.describe User do
  subject(:user) { build(:user) }

  describe "associations" do
    it { is_expected.to belong_to(:current_game).class_name("Game").optional }
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:web_push_subscriptions).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to have_secure_password }

    it { is_expected.to validate_inclusion_of(:theme).in_array(User::ALL_THEMES) }

    it "allows blank kuma_url" do
      user.kuma_url = ""
      expect(user).to be_valid
    end

    it "allows valid http kuma_url" do
      user.kuma_url = "http://kuma.local:3001"
      expect(user).to be_valid
    end

    it "allows valid https kuma_url" do
      user.kuma_url = "https://kuma.example.com"
      expect(user).to be_valid
    end

    it "rejects non-http kuma_url" do
      user.kuma_url = "ftp://kuma.local"
      expect(user).not_to be_valid
      expect(user.errors[:kuma_url]).to include("must be an HTTP or HTTPS URL")
    end
  end

  describe "normalizations" do
    it "strips and downcases username" do
      user = create(:user, username: "  Admin  ")
      expect(user.username).to eq("admin")
    end
  end

  describe "api_token" do
    it "generates an api_token on create" do
      user = create(:user)
      expect(user.api_token).to be_present
    end

    it "does not overwrite an existing api_token" do
      user = create(:user, api_token: "custom_token")
      expect(user.api_token).to eq("custom_token")
    end
  end

  describe "#regenerate_api_token!" do
    it "replaces the api_token" do
      user = create(:user)
      old_token = user.api_token

      user.regenerate_api_token!

      expect(user.api_token).not_to eq(old_token)
      expect(user.api_token).to be_present
    end
  end

  describe "THEMES" do
    it "includes dracula as a dark theme" do
      expect(User::THEMES["Dark"]).to include("dracula")
    end

    it "includes light as a light theme" do
      expect(User::THEMES["Light"]).to include("light")
    end

    it "ALL_THEMES is a flat array of all themes" do
      expect(User::ALL_THEMES).to include("dracula", "light", "night", "cupcake")
    end
  end
end
