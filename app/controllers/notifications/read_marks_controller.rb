module Notifications
  class ReadMarksController < ApplicationController
    def create
      current_user.notifications.where(read_at: nil).update_all(read_at: Time.current)

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
