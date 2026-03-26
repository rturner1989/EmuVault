require "rails_helper"

RSpec.describe "Onboarding::Games" do
  let(:user) { sign_in(create(:user, setup_completed: false)) }

  before do
    user
    create(:emulator_profile, user_selected: true, game_system: :gba)
  end

  describe "GET /onboarding/games" do
    it "renders the add games step" do
      get onboarding_games_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Add your games")
    end

    it "shows the Complete Setup button when games exist" do
      create(:game, title: "Zelda", system: :gba)

      get onboarding_games_path

      expect(response.body).to include("Complete Setup")
    end

    it "does not show the Complete Setup button when no games exist" do
      get onboarding_games_path

      expect(response.body).not_to include("Complete Setup")
    end

    it "only shows systems with selected emulator profiles" do
      get onboarding_games_path

      expect(response.body).to include("Game Boy Advance")
      expect(response.body).not_to include("SNES")
    end

    it "redirects to root when setup is already complete" do
      user.update!(setup_completed: true)

      get onboarding_games_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /onboarding/games" do
    it "creates a game" do
      post onboarding_games_path,
        params: { game: { title: "Zelda", system: "gba" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(Game.count).to eq(1)
      expect(Game.last.title).to eq("Zelda")
    end

    it "rejects invalid params" do
      post onboarding_games_path,
        params: { game: { title: "", system: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(Game.count).to eq(0)
    end
  end

  describe "DELETE /onboarding/games/:id" do
    it "destroys the game" do
      game = create(:game, title: "Zelda", system: :gba)

      delete onboarding_game_path(game),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(Game.exists?(game.id)).to be(false)
    end

    it "shows a flash message on success" do
      game = create(:game, title: "Zelda", system: :gba)

      delete onboarding_game_path(game),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("Zelda removed")
    end
  end
end
