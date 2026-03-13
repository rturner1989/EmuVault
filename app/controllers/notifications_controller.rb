# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    @notifications = Current.user.notifications
                            .includes(event: {})
                            .order(created_at: :desc)
                            .limit(20)
  end

  def mark_all_read
    Current.user.notifications.where(read_at: nil).update_all(read_at: Time.current)

    Turbo::StreamsChannel.broadcast_replace_to(
      "notifications_#{Current.user.id}",
      targets: "[data-notification-badge]",
      partial: "shared/notification_badge",
      locals: { count: 0 }
    )

    head :ok
  end
end
