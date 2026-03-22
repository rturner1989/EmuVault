# frozen_string_literal: true

module UI
  class ActionComponent < ApplicationComponent
    renders_one :leading_icon, "UI::IconComponent"
    renders_one :trailing_icon, "UI::IconComponent"

    LINK_VARIANTS = %i[link link_primary link_secondary link_accent link_neutral
                       link_success link_info link_warning link_error].to_set.freeze

    def initialize(href: nil, method: nil, params: nil, form: nil, variant: :secondary, size: :sm, disabled: false, **kwargs)
      @href = href
      @method = method
      @params = params
      @form = form
      @link = LINK_VARIANTS.include?(variant.to_sym)
      extra_class = kwargs.delete(:class)
      computed = style(:action, variant: variant.to_sym, size: @link ? :md : size.to_sym, disabled: disabled)
      final_class = (computed + [extra_class]).compact.reject(&:empty?).join(" ")
      @kwargs = kwargs.merge(class: final_class)
      @kwargs[:disabled] = true if disabled
    end

    private def form_action?
      @href && @method
    end

    style :action,
      default: "",
      variant: {
        primary: "btn btn-primary",
        secondary: "btn btn-soft",
        ghost: "btn btn-ghost",
        danger: "btn btn-error btn-outline",
        info: "btn btn-info",
        warning: "btn btn-warning btn-outline",
        link: "link",
        link_primary: "link link-primary",
        link_secondary: "link link-secondary",
        link_accent: "link link-accent",
        link_neutral: "link link-neutral",
        link_success: "link link-success",
        link_info: "link link-info",
        link_warning: "link link-warning",
        link_error: "link link-error"
      },
      size: {
        xs: "btn-xs",
        sm: "btn-sm",
        md: "",
        full: "btn-sm w-full"
      },
      disabled: {
        true => "cursor-not-allowed opacity-60",
        false => ""
      }
  end
end
