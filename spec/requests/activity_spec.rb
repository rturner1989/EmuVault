require "rails_helper"

RSpec.describe "Activity" do
  let(:user) { sign_in }

  before { user }

  describe "GET /activity" do
    it "renders the activity page" do
      get activity_path

      expect(response).to have_http_status(:ok)
    end

    it "shows sync events" do
      game = create(:game, title: "Zelda")
      game_save = create(:game_save, game: game)
      create(:sync_event, game_save: game_save, action: :push)

      get activity_path

      expect(response.body).to include("Zelda")
    end

    it "sorts by oldest" do
      get activity_path, params: { sort: "oldest" }

      expect(response).to have_http_status(:ok)
    end
  end
end
