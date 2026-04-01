class DashboardController < MainController
  include ActiveSupport::NumberHelper

  def index
    @game = Game.new
    @games_count = Game.count
    @games_without_save = Game.without_saves.count
    @sync_events_count = SyncEvent.count
    @storage_used = number_to_human_size(Game.storage_used_bytes)
    @recent_sync_events = SyncEvent.includes(game_save: :game).recent.limit(5)
    @top_games = Game.top_by_sync_events
    @system_counts = Game.group(:system).count
  end
end
