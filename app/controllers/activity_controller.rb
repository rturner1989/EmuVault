class ActivityController < MainController
  def show
    @games = Game.with_activity
    @selected_game_id = params[:game_id].presence
    @selected_sort = params[:sort].presence || "newest"

    events = SyncEvent.includes(game_save: :game)
    events = events.for_game(@selected_game_id) if @selected_game_id
    events = @selected_sort == "oldest" ? events.oldest_first : events.recent

    @total_count = events.count
    @pagy, @events = pagy(events, limit: 20)
  end
end
