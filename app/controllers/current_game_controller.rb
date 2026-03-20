class CurrentGameController < ApplicationController
  before_action :set_game

  def update
    authorize! @game, to: :update?

    current_user.update!(current_game: @game)
    respond_with_game("Now playing: #{@game.title}")
  end

  def destroy
    authorize! @game

    current_user.update!(current_game: nil)
    respond_with_game("Cleared current game")
  end

  private def set_game
    @game = Game.find(params[:game_id])
  end

  private def respond_with_game(notice)
    if params[:inline]
      load_quick_sync_data
      @form = GameForm.from(@game)
      @games = GameDecorator.decorate(Game.order(:title))
      @decorated_game = GameDecorator.new(@game)
      @notice = notice
    else
      redirect_back_or_to root_path, notice: notice
    end
  end
end
