# frozen_string_literal: true

module Layouts
  class AppShellComponent < ApplicationComponent
    renders_one :content_body

    def initialize(current_path:, onboarding: false)
      @current_path = current_path
      @onboarding = onboarding
    end

    def nav_link_class(path)
      active = active_path?(path)
      base = "flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors"
      if active
        "#{base} bg-base-300 text-primary"
      else
        "#{base} text-muted hover:bg-base-300 hover:text-base-content"
      end
    end

    def mobile_nav_class(path)
      active = active_path?(path)
      base = "flex items-center justify-center flex-1 py-4 text-lg transition-colors"
      active ? "#{base} text-primary" : "#{base} text-muted hover:text-base-content"
    end

    def unread_count
      current_user.notifications.where(read_at: nil).count
    end

    private def active_path?(path)
      return @current_path == "/" if path == "/"

      @current_path.start_with?(path)
    end
  end
end
