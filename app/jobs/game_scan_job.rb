class GameScanJob < ApplicationJob
  queue_as :default

  # mode: "dry_run"  — discover ROMs, store findings, no DB writes
  # mode: "confirm"  — import a specific list of items (from review step)
  # mode: "auto"     — import all new ROMs from auto_scan paths (scheduled)
  # mode: "auto_all" — import all ROMs from all paths (onboarding)
  def perform(mode = "auto", items = nil)
    user = User.first
    scanner = GameScanner.new

    case mode
    when "dry_run"
      result = scanner.collect(ScanPath.ordered)
      result["status"] = "pending_review"
      user.update!(last_scan_result: result)
      broadcast_dry_run_complete(user, result)

    when "confirm"
      broadcast_scan_start(user)
      result = scanner.import_items(items || []) { |game| broadcast_game_added(user, game) }
      result["status"] = "completed"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)
      broadcast_import_complete(user, result)

    when "auto"
      return unless user.scan_enabled? && user.scan_due?

      result = scanner.collect(ScanPath.for_auto_scan)
      result["status"] = "pending_review"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)
      notify_scan_results(user, result) if (result["found"] || []).any?

    when "auto_all"
      broadcast_scan_start(user)
      result = scanner.import_all(ScanPath.ordered) { |game| broadcast_game_added(user, game) }
      result["status"] = "completed"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)
      broadcast_import_complete(user, result)
      result
    end
  end

  # --- Notifications ---

  private def notify_scan_results(user, result)
    found = (result["found"] || []).size
    ScanCompleteNotifier.with(found: found).deliver(user)

    count = user.notifications.where(read_at: nil).count
    Turbo::StreamsChannel.broadcast_replace_later_to(
      "notifications_#{user.id}",
      targets: "[data-notification-badge]",
      partial: "shared/notification_badge",
      locals: { count: count }
    )
  end

  # --- Broadcasts ---

  private def broadcast_scan_start(user)
    user.update!(last_scan_result: { "status" => "scanning" })
  end

  private def broadcast_game_added(user, game)
    # Append to onboarding game list (no-op if not on onboarding page)
    Turbo::StreamsChannel.broadcast_append_to(
      "scans_#{user.id}",
      target: "onboarding-games-list",
      html: ApplicationController.render(partial: "games/onboarding_game_list_item", locals: { game: game })
    )

    # Append to main game list (no-op if not on games index)
    Turbo::StreamsChannel.broadcast_append_to(
      "scans_#{user.id}",
      target: "games-list",
      html: ApplicationController.render(partial: "games/game_list_item", locals: { game: game, current_game_id: user.current_game_id })
    )
  end

  private def broadcast_dry_run_complete(user, result)
    found = result["found"] || []
    already_in_lib = result["already_in_lib"] || 0
    skipped_paths = result["skipped_paths"] || []
    grouped = found.group_by { |item| item["game_system"] }

    # Replace spinner with review content inside the modal
    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "scan-review-content",
      html: ApplicationController.render(
        partial: "games/scans/review_content",
        locals: { found: found, already_in_lib: already_in_lib, skipped_paths: skipped_paths, grouped: grouped }
      )
    )
  end

  private def broadcast_import_complete(user, result)
    added = result["added"] || 0
    message = added > 0 ? "#{added} #{"game".pluralize(added)} imported." : "No new games found."

    # Clear onboarding scan spinner (no-op if not on onboarding page)
    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "scan-progress",
      html: ""
    )

    # Flash message
    Turbo::StreamsChannel.broadcast_append_to(
      "scans_#{user.id}",
      target: "flash-container",
      html: ApplicationController.render(Layouts::FlashComponent::Item.new(type: :notice, message: message), layout: false)
    )

    # Update game filters and stats (no-op if not on games index)
    games_count = Game.count
    system_options = Game::GAME_SYSTEM_OPTIONS.select { |_text, value| Game.distinct.pluck(:system).compact.include?(value) }

    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "games-filters",
      html: ApplicationController.render(
        partial: "games/filters",
        locals: { games_count: games_count, system_options: system_options, selected_system: nil, selected_sort: "title_asc" }
      )
    )

    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "game_stats",
      html: ApplicationController.render(
        partial: "shared/game_stats",
        locals: { games_count: games_count, games_without_save: Game.left_joins(:game_saves).where(game_saves: { id: nil }).count }
      )
    )

    # Update onboarding banner (no-op if not on onboarding page)
    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "onboarding-banner",
      html: ApplicationController.render(
        partial: "shared/onboarding_banner",
        locals: {
          step: 2,
          title: "Add your games",
          description: "Configure scan paths to discover games automatically, or add them manually.",
          back_path: Rails.application.routes.url_helpers.onboarding_emulator_profiles_path,
          next_path: (Rails.application.routes.url_helpers.onboarding_completion_path if Game.exists?),
          next_label: "Complete Setup",
          next_method: (Game.exists? ? :post : nil)
        },
        layout: false
      )
    )
  end
end
