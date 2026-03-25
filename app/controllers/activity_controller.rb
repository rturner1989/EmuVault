class ActivityController < MainController
  PREVIEW_COUNT = 5

  def show
    @games = Game.joins(game_saves: :sync_events).distinct.order(:title)
    @selected_game_id = params[:game_id].presence
    @selected_sort = params[:sort].presence || "newest"

    events = SyncEvent.includes(game_save: :game)
    events = events.joins(game_save: :game).where(games: { id: @selected_game_id }) if @selected_game_id
    events = @selected_sort == "oldest" ? events.order(performed_at: :asc) : events.order(performed_at: :desc)

    @total_count = events.count
    @events = events
  end
end
