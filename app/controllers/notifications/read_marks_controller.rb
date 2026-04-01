module Notifications
  class ReadMarksController < MainController
    def create
      current_user.mark_all_notifications_read!

      Turbo::StreamsChannel.broadcast_replace_to(
        "notifications_#{current_user.id}",
        targets: "[data-notification-badge]",
        partial: "shared/notification_badge",
        locals: { count: 0 }
      )

      head :ok
    end
  end
end
