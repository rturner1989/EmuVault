require "rails_helper"

RSpec.describe "CurrentGame" do
  let(:user) { sign_in }
  let(:game) { create(:game) }

  before { user }

  describe "PATCH /current_game" do
    it "sets the current game" do
      patch current_game_path, params: { game_id: game.id }

      expect(user.reload.current_game).to eq(game)
    end
  end

  describe "DELETE /current_game" do
    it "clears the current game" do
      user.update!(current_game: game)

      delete current_game_path, params: { game_id: game.id }

      expect(user.reload.current_game).to be_nil
    end
  end
end
