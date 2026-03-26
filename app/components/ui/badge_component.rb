# frozen_string_literal: true

module UI
  class BadgeComponent < ApplicationComponent
    renders_one :icon, "UI::IconComponent"

    COLORS = {
      purple: "badge badge-primary",
      green: "badge badge-success",
      cyan: "badge badge-info",
      yellow: "badge badge-warning",
      pink: "badge badge-secondary",
      orange: "badge badge-accent",
      red: "badge badge-error",
      comment: "badge badge-ghost text-muted"
    }.freeze

    SIZES = {
      xs: "badge-xs",
      sm: "badge-sm",
      md: "",
      lg: "badge-lg"
    }.freeze

    def initialize(color: :comment, size: :sm, **kwargs)
      extra = kwargs.delete(:class)
      classes = [
        COLORS[color.to_sym],
        SIZES[size.to_sym],
        extra
      ].compact.reject(&:empty?).join(" ")
      @kwargs = kwargs.merge(class: classes)
    end
  end
end
