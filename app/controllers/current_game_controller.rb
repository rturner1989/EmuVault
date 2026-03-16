class CurrentGameController < ApplicationController
  def update
    game = Game.find(params[:game_id])
    current_user.update!(current_game: game)
    redirect_back_or_to root_path, notice: "Now playing: #{game.title}"
  end

  def destroy
    current_user.update!(current_game: nil)
    redirect_back_or_to root_path
  end
end
