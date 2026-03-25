class DashboardController < ApplicationController
  include ActiveSupport::NumberHelper

  def index
    @game = Game.new
    @games_count = Game.count
    @games_without_save = Game.left_joins(:game_saves).where(game_saves: { id: nil }).count
    @sync_events_count = SyncEvent.count

    @storage_used = number_to_human_size(
      ActiveStorage::Attachment.joins(:blob)
        .where(record_type: "GameSave", name: "file")
        .sum("active_storage_blobs.byte_size")
    )

    @recent_sync_events = SyncEvent.includes(game_save: :game).recent.limit(5)
    @top_games = SyncEvent.joins(game_save: :game)
                          .group("games.id", "games.title")
                          .order(Arel.sql("COUNT(*) DESC"))
                          .limit(5)
                          .count("games.id")
                          .map { |(id, title), count| { id:, title:, count: } }
    @system_counts = Game.group(:system).count
  end
end
