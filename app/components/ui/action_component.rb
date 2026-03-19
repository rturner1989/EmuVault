# frozen_string_literal: true

module UI
  class ActionComponent < ApplicationComponent
    renders_one :leading_icon, "UI::IconComponent"
    renders_one :trailing_icon, "UI::IconComponent"

    VARIANTS = {
      primary: "btn btn-primary",
      secondary: "btn btn-soft",
      ghost: "btn btn-ghost",
      danger: "btn btn-error btn-outline",
      info: "btn btn-info",
      warning: "btn btn-warning btn-outline",
      default: ""
    }.freeze

    SIZES = {
      xs: "btn-xs",
      sm: "btn-sm",
      md: "",
      full: "btn-sm w-full"
    }.freeze

    def initialize(content_text: nil, href: nil, variant: :secondary, size: :sm, **html_options)
      @content_text = content_text
      @href = href
      size_class = SIZES.fetch(size.to_sym, "btn-sm")
      variant_class = VARIANTS.fetch(variant.to_sym, VARIANTS[:default])
      base_class = [ variant_class, size_class ].reject(&:empty?).join(" ")
      extra_class = html_options.delete(:class)
      final_class = [ base_class, extra_class ].compact.join(" ")
      @html_options = html_options.merge(class: final_class)
    end
  end
end
