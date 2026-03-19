class CurrentGameController < ApplicationController
  def update
    game = Game.find(params[:game_id])
    current_user.update!(current_game: game)
    if params[:inline]
      load_quick_sync_data
      streams = source_streams(game)
      streams << turbo_stream.update(:quick_sync_content,
        partial: "shared/quick_sync_content")
      streams << turbo_stream.append("flash-container",
        ::Layouts::FlashComponent::Item.new(type: :notice, message: "Now playing: #{game.title}"))
      render turbo_stream: streams
    else
      redirect_back_or_to root_path, notice: "Now playing: #{game.title}"
    end
  end

  def destroy
    current_user.update!(current_game: nil)
    if params[:inline]
      load_quick_sync_data
      streams = source_streams(params[:game_id] ? Game.find(params[:game_id]) : nil)
      streams << turbo_stream.update(:quick_sync_content,
        partial: "shared/quick_sync_content")
      streams << turbo_stream.append("flash-container",
        ::Layouts::FlashComponent::Item.new(type: :notice, message: "Cleared current game"))
      render turbo_stream: streams
    else
      redirect_back_or_to root_path
    end
  end

  private def source_streams(game)
    case params[:source]
    when "index"
      games = GameDecorator.decorate(Game.order(:title))
      [turbo_stream.update("games-list",
        partial: "games/game_list",
        locals: { games: games })]
    else
      return [] unless game
      @form = GameForm.from(game)
      [turbo_stream.replace("game_header",
        partial: "games/header",
        locals: { game: GameDecorator.new(game) })]
    end
  end
end
