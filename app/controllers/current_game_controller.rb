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
      games = GameDecorator.decorate(Game.order(:title))

      render turbo_stream: [
        turbo_stream.update("games-list", partial: "games/game_list", locals: { games: games }),
        turbo_stream.replace("game_header", partial: "games/header", locals: { game: GameDecorator.new(@game) }),
        turbo_stream.update(:quick_sync_content, partial: "shared/quick_sync_content"),
        turbo_stream.update(:now_playing, partial: "shared/now_playing"),
        turbo_stream.append("flash-container", ::Layouts::FlashComponent::Item.new(type: :notice, message: notice))
      ]
    else
      redirect_back_or_to root_path, notice: notice
    end
  end
end
