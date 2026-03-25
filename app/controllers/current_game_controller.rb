class CurrentGameController < MainController
  before_action :set_game

  def update
    current_user.update!(current_game: @game)
    respond_with_game("Now playing: #{@game.title}")
  end

  def destroy
    current_user.update!(current_game: nil)
    respond_with_game("Cleared current game")
  end

  private def set_game
    @game = Game.find(params[:game_id])
  end

  private def respond_with_game(notice)
    if params[:inline]
      load_quick_sync_data
      @games = Game.order(:title)
      @notice = notice
    else
      redirect_back_or_to root_path, notice: notice
    end
  end
end
