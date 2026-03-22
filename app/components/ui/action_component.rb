# frozen_string_literal: true

module UI
  class ActionComponent < ApplicationComponent
    renders_one :leading_icon, "UI::IconComponent"
    renders_one :trailing_icon, "UI::IconComponent"

    def initialize(content_text: nil, href: nil, variant: :secondary, size: :sm, disabled: false, **kwargs)
      @content_text = content_text
      @href = href
      extra_class = kwargs.delete(:class)
      computed = style(:action, variant: variant.to_sym, size: size.to_sym, disabled: disabled)
      final_class = (computed + [extra_class]).compact.reject(&:empty?).join(" ")
      @kwargs = kwargs.merge(class: final_class)
      @kwargs[:disabled] = true if disabled
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
        default: ""
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
