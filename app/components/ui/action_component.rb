# frozen_string_literal: true

module UI
  class ActionComponent < ApplicationComponent
    renders_one :leading_icon, "UI::IconComponent"
    renders_one :trailing_icon, "UI::IconComponent"

    LINK_VARIANTS = %i[link link_primary link_secondary link_accent link_neutral
                       link_success link_info link_warning link_error].to_set.freeze

    VARIANTS = {
      primary: "btn btn-primary",
      secondary: "btn btn-soft",
      ghost: "btn btn-ghost",
      outline: "btn btn-primary btn-outline",
      danger: "btn btn-error btn-outline",
      info: "btn btn-info",
      warning: "btn btn-warning btn-outline",
      link: "link no-underline",
      link_primary: "link link-primary no-underline",
      link_secondary: "link link-secondary no-underline",
      link_accent: "link link-accent no-underline",
      link_neutral: "link link-neutral no-underline",
      link_success: "link link-success no-underline",
      link_info: "link link-info no-underline",
      link_warning: "link link-warning no-underline",
      link_error: "link link-error no-underline"
    }.freeze

    SIZES = {
      xs: "btn-xs",
      sm: "btn-sm",
      md: "",
      full: "btn-sm w-full"
    }.freeze

    def initialize(href: nil, variant: :secondary, size: :sm, disabled: false, **kwargs)
      @href = href
      @link = LINK_VARIANTS.include?(variant.to_sym)
      extra_class = kwargs.delete(:class)
      classes = [
        VARIANTS[variant.to_sym],
        @link ? nil : SIZES[size.to_sym],
        ("cursor-not-allowed opacity-60" if disabled),
        extra_class
      ].compact.reject(&:empty?).join(" ")
      @kwargs = kwargs.merge(class: classes)
      @kwargs[:disabled] = true if disabled
    end

    private def form_action?
      @href && @kwargs[:method]
    end
  end
end
