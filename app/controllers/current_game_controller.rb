class CurrentGameController < ApplicationController
  def update
    game = Game.find(params[:game_id])
    current_user.update!(current_game: game)
    if params[:inline]
      @form = GameForm.from(game)
      render turbo_stream: turbo_stream.replace("game_header",
        partial: "games/header",
        locals: { game: GameDecorator.new(game) })
    else
      redirect_back_or_to root_path, notice: "Now playing: #{game.title}"
    end
  end

  def destroy
    current_user.update!(current_game: nil)
    if params[:inline] && params[:game_id]
      game = Game.find(params[:game_id])
      @form = GameForm.from(game)
      render turbo_stream: turbo_stream.replace("game_header",
        partial: "games/header",
        locals: { game: GameDecorator.new(game) })
    else
      redirect_back_or_to root_path
    end
  end
end
