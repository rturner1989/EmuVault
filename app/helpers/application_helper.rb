module ApplicationHelper
  PLATFORM_COLORS = {
    linux: :purple,
    windows: :cyan,
    macos: :green,
    ios: :pink,
    android: :orange
  }.freeze

  def platform_badge_color(platform)
    PLATFORM_COLORS.fetch(platform.to_sym, :comment)
  end
end
