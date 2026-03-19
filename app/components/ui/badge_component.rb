# frozen_string_literal: true

module UI
  class BadgeComponent < ApplicationComponent
    COLOR_CLASSES = {
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

    renders_one :icon, "UI::IconComponent"

    def initialize(context_text: nil, color: :comment, size: :sm, **html_options)
      @content_text = context_text
      color_cls = COLOR_CLASSES.fetch(color.to_sym, COLOR_CLASSES[:comment])
      size_cls = SIZES.fetch(size.to_sym, "badge-sm")
      base = [ color_cls, size_cls ].reject(&:empty?).join(" ")
      extra = html_options.delete(:class)
      @class = extra ? "#{base} #{extra}" : base
      @html_options = html_options
    end
  end
end
