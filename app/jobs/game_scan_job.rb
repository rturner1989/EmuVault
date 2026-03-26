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

    when "confirm"
      broadcast_scan_start(user)
      result = scanner.import_items(items || []) { |game| broadcast_game_added(user, game) }
      result["status"] = "completed"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)
      broadcast_scan_complete(user, result)

    when "auto"
      return unless user.scan_enabled? && user.scan_due?

      result = scanner.import_all(ScanPath.for_auto_scan)
      result["status"] = "completed"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)
      notify_scan_complete(user, result) if (result["added"] || 0) > 0

    when "auto_all"
      broadcast_scan_start(user)
      result = scanner.import_all(ScanPath.ordered) { |game| broadcast_game_added(user, game) }
      result["status"] = "completed"
      user.update!(last_scanned_at: Time.current, last_scan_result: result)
      broadcast_scan_complete(user, result)
      result
    end
  end

  # --- Notifications ---

  private def notify_scan_complete(user, result)
    added = result["added"] || 0
    ScanCompleteNotifier.with(added: added).deliver(user)

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

    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "scan-progress",
      html: ApplicationController.render(partial: "games/scan_progress", layout: false)
    )
  end

  private def broadcast_game_added(user, game)
    Turbo::StreamsChannel.broadcast_append_to(
      "scans_#{user.id}",
      target: "onboarding-games-list",
      html: ApplicationController.render(partial: "games/onboarding_game_list_item", locals: { game: game })
    )
  end

  private def broadcast_scan_complete(user, result)
    added = result["added"] || 0
    message = added > 0 ? "#{added} #{"game".pluralize(added)} imported." : "No new games found."

    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "scan-progress",
      html: ""
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "scans_#{user.id}",
      target: "flash-container",
      html: ApplicationController.render(Layouts::FlashComponent::Item.new(type: :notice, message: message), layout: false)
    )

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
