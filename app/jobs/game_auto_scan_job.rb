# frozen_string_literal: true

class GameAutoScanJob < ApplicationJob
  queue_as :default

  def perform
    user = User.first
    return unless user&.scan_enabled? && user.scan_due?

    result = GameScanner.new.collect(ScanPath.for_auto_scan)
    result["status"] = "pending_review"
    user.update!(last_scanned_at: Time.current, last_scan_result: result)
    notify_scan_results(user, result) if (result["found"] || []).any?
  end

  private def notify_scan_results(user, result)
    return if unread_scan_notification?(user)

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

  private def unread_scan_notification?(user)
    user.notifications
      .joins(:event)
      .where(read_at: nil)
      .where(noticed_events: { type: "ScanCompleteNotifier" })
      .exists?
  end
end
