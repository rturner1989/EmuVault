require "rails_helper"

RSpec.describe "GameSaves" do
  let(:user) { sign_in }
  let(:game) { create(:game) }

  before { user }

  describe "POST /games/:game_id/game_saves" do
    it "creates a game save with a file" do
      file = Rack::Test::UploadedFile.new(StringIO.new("save data"), "application/octet-stream", true, original_filename: "save.srm")

      post game_game_saves_path(game), params: { game_save: { file: file } }

      expect(response).to redirect_to(game_path(game))
      expect(game.game_saves.count).to eq(1)
    end

    it "creates a sync event on upload" do
      file = Rack::Test::UploadedFile.new(StringIO.new("save data"), "application/octet-stream", true, original_filename: "save.srm")

      post game_game_saves_path(game), params: { game_save: { file: file } }

      event = SyncEvent.last
      expect(event.action).to eq("push")
      expect(event.status).to eq("success")
    end
  end

  describe "DELETE /games/:game_id/game_saves/:id" do
    it "destroys the game save" do
      game_save = create(:game_save, game: game)

      delete game_game_save_path(game, game_save)

      expect(response).to redirect_to(game_path(game))
      expect(GameSave.exists?(game_save.id)).to be(false)
    end
  end

  describe "GET /games/:game_id/game_saves/:id/download" do
    it "downloads the save file" do
      game_save = create(:game_save, game: game)

      get download_game_game_save_path(game, game_save)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
    end

    it "creates a sync event on download" do
      game_save = create(:game_save, game: game)

      get download_game_game_save_path(game, game_save)

      event = SyncEvent.last
      expect(event.action).to eq("pull")
      expect(event.status).to eq("success")
    end
  end
end
