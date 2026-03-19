# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    authorize! Notification

    @notifications = Current.user.notifications
                            .where(read_at: nil)
                            .includes(event: {})
                            .order(created_at: :desc)
                            .limit(20)
  end

  def show
    notification = Current.user.notifications.find(params[:id])
    authorize! notification

    notification.update!(read_at: Time.current) unless notification.read_at

    count = Current.user.notifications.where(read_at: nil).count
    Turbo::StreamsChannel.broadcast_replace_later_to(
      "notifications_#{Current.user.id}",
      targets: "[data-notification-badge]",
      partial: "shared/notification_badge",
      locals: { count: count }
    )

    redirect_to game_path(notification.game)
  end

  def mark_all_read
    authorize! Notification

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
