# frozen_string_literal: true

module Layouts
  class AppShellComponent < ApplicationComponent
    renders_one :content_body

    def initialize(current_path:)
      @current_path = current_path
    end

    def nav_link_class(path)
      active = active_path?(path)
      base = "flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors"
      if active
        "#{base} bg-drac-current text-drac-purple"
      else
        "#{base} text-drac-comment hover:bg-drac-current hover:text-drac-fg"
      end
    end

    def mobile_nav_class(path)
      active = active_path?(path)
      base = "flex items-center justify-center flex-1 py-4 text-lg transition-colors"
      active ? "#{base} text-drac-purple" : "#{base} text-drac-comment hover:text-drac-fg"
    end

    def unread_count
      Current.user.notifications.where(read_at: nil).count
    end

    private

    def active_path?(path)
      return @current_path == "/" if path == "/"

      @current_path.start_with?(path)
    end
  end
end
