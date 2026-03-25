class DashboardController < ApplicationController
  def index
    @form = GameForm.new
    @games_count = Game.count
    @games_without_save = Game.left_joins(:game_saves).where(game_saves: { id: nil }).count
    @sync_events_count = SyncEvent.count

    @storage_used = storage_label(
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

  private def storage_label(bytes)
    if bytes >= 1_048_576
      format("%.1f MB", bytes.to_f / 1_048_576)
    elsif bytes >= 1_024
      format("%.1f KB", bytes.to_f / 1_024)
    else
      "#{bytes} B"
    end
  end
end
