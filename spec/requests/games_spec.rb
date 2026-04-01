require "rails_helper"

RSpec.describe "Games" do
  let(:user) { sign_in }

  before { user }

  describe "GET /games" do
    it "requires authentication" do
      reset!
      create(:user)

      get games_path

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the games list" do
      create(:game, title: "Zelda")

      get games_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Zelda")
    end

    it "filters by system" do
      create(:game, title: "Zelda", system: :snes)
      create(:game, title: "Pokemon", system: :gba)

      get games_path, params: { system: "snes" }

      expect(response.body).to include("Zelda")
      expect(response.body).not_to include("Pokemon")
    end

    it "sorts by title descending" do
      create(:game, title: "Alpha")
      create(:game, title: "Zeta")

      get games_path, params: { sort: "title_desc" }

      expect(response.body.index("Zeta")).to be < response.body.index("Alpha")
    end

    it "returns paginated content for paginate param" do
      create_list(:game, 10)
      create(:game, title: "Extra Game")

      get games_path, params: { page: 2, paginate: true }

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("<html")
    end

    context "with pending auto-scan results" do
      before do
        user.update!(last_scan_result: {
          "status" => "pending_review",
          "found" => [ { "title" => "Zelda", "game_system" => "gba", "rom_path" => "/roms/Zelda.gba", "save_files" => [] } ],
          "already_in_lib" => 0,
          "skipped_paths" => []
        })
      end

      it "includes the review modal content" do
        get games_path

        expect(response.body).to include("Zelda")
        expect(response.body).to include("scan-review-dialog")
      end

      it "sets auto_open on the review modal" do
        get games_path

        expect(response.body).to include("auto-open-value")
      end
    end
  end

  describe "GET /games/:id" do
    it "renders the game show page" do
      game = create(:game, title: "Zelda")

      get game_path(game)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Zelda")
    end
  end

  describe "POST /games" do
    it "creates a game with valid params" do
      post games_path, params: { game: { title: "Zelda", system: "snes" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(Game.count).to eq(1)
      expect(Game.last.title).to eq("Zelda")
    end

    it "rejects invalid params" do
      post games_path, params: { game: { title: "", system: "" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(Game.count).to eq(0)
    end
  end

  describe "PATCH /games/:id" do
    let(:game) { create(:game, title: "Zelda", system: :snes) }

    it "updates the game" do
      patch game_path(game), params: { game: { title: "Zelda II", system: "snes" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(game.reload.title).to eq("Zelda II")
    end

    it "rejects invalid params" do
      patch game_path(game), params: { game: { title: "" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(game.reload.title).to eq("Zelda")
    end
  end

  describe "DELETE /games/:id" do
    it "destroys the game and redirects" do
      game = create(:game)

      delete game_path(game)

      expect(response).to redirect_to(games_path)
      expect(Game.exists?(game.id)).to be(false)
    end

    it "clears current_game if it was the current game" do
      game = create(:game)
      user.update!(current_game: game)

      delete game_path(game)

      expect(user.reload.current_game).to be_nil
    end
  end
end
