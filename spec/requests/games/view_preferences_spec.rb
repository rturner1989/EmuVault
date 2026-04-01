require "rails_helper"

RSpec.describe "Games::ViewPreferences" do
  let(:user) { sign_in }

  before { user }

  describe "PATCH /games_view_preference" do
    it "updates the user's view preference to list" do
      patch games_view_preference_path(view: "list")

      expect(user.reload.games_view_preference).to eq("list")
    end

    it "updates the user's view preference to card" do
      user.update!(games_view_preference: "list")

      patch games_view_preference_path(view: "card")

      expect(user.reload.games_view_preference).to eq("card")
    end

    it "ignores invalid view values" do
      patch games_view_preference_path(view: "invalid")

      expect(user.reload.games_view_preference).to eq("card")
    end

    it "redirects to the games index" do
      patch games_view_preference_path(view: "list")

      expect(response).to redirect_to(games_path)
    end

    it "preserves sort and system params in the redirect" do
      patch games_view_preference_path(view: "list", sort: "newest", system: "gba")

      expect(response).to redirect_to(games_path(sort: "newest", system: "gba"))
    end
  end
end
