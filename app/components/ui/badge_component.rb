# frozen_string_literal: true

module UI
  class BadgeComponent < ApplicationComponent
    renders_one :icon, "UI::IconComponent"

    def initialize(context_text: nil, color: :comment, size: :sm, **kwargs)
      @content_text = context_text
      extra = kwargs.delete(:class)
      computed = style(:badge, color: color.to_sym, size: size.to_sym)
      @class = (computed + [extra]).compact.reject(&:empty?).join(" ")
      @kwargs = kwargs
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
