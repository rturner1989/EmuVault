# frozen_string_literal: true

module UI
  class BadgeComponent < ApplicationComponent
    renders_one :icon, "UI::IconComponent"

    def initialize(color: :comment, size: :sm, **kwargs)
      extra = kwargs.delete(:class)
      computed = style(:badge, color: color.to_sym, size: size.to_sym)
      @kwargs = kwargs.merge(class: (computed + [ extra ]).compact.reject(&:empty?).join(" "))
    end

    style :badge,
      default: "",
      color: {
        purple: "badge badge-primary",
        green: "badge badge-success",
        cyan: "badge badge-info",
        yellow: "badge badge-warning",
        pink: "badge badge-secondary",
        orange: "badge badge-accent",
        red: "badge badge-error",
        comment: "badge badge-ghost text-muted"
      },
      size: {
        xs: "badge-xs",
        sm: "badge-sm",
        md: "",
        lg: "badge-lg"
      }
  end
end
