# frozen_string_literal: true

class NotificationsController < MainController
  def index
    @notifications = current_user.notifications
      .where(read_at: nil)
      .includes(event: {})
      .order(created_at: :desc)
      .limit(20)
  end

  def show
    notification = current_user.notifications.find(params[:id])
    notification.update!(read_at: Time.current) unless notification.read_at

    count = current_user.notifications.where(read_at: nil).count
    Turbo::StreamsChannel.broadcast_replace_later_to(
      "notifications_#{current_user.id}",
      targets: "[data-notification-badge]",
      partial: "shared/notification_badge",
      locals: { count: count }
    )

    redirect_to notification.game ? game_path(notification.game) : games_path
  end
end
