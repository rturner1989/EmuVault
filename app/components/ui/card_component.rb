# frozen_string_literal: true

module UI
  class CardComponent < ApplicationComponent
    renders_one :header
    renders_one :footer
    renders_one :body
    renders_many :footer_actions, "UI::ActionComponent"

    def initialize(padding: :md, scrollable: false, **kwargs)
      @padding = padding.to_sym
      @scrollable = scrollable
      extra_class = kwargs.delete(:class)
      computed = style(:card, scrollable: scrollable)
      @class = (computed + [extra_class]).compact.reject(&:empty?).join(" ")
      @kwargs = kwargs
    end

    def padding_class
      style(:card_padding, padding: @padding).compact.reject(&:empty?).join(" ")
    end

    def content_class
      @scrollable ? "overflow-y-auto flex-1 min-h-0" : nil
    end

    def body_class
      (style(:card_body, scrollable: @scrollable) + [padding_class]).compact.reject(&:empty?).join(" ")
    end

    style :card,
      default: "rounded-lg overflow-hidden bg-base-100 border border-base-300",
      scrollable: {
        true => "flex flex-col min-h-0",
        false => ""
      }

    style :card_padding,
      padding: {
        sm: "px-4 py-3",
        md: "px-5 py-4"
      }

    style :card_body,
      scrollable: {
        true => "overflow-y-auto flex-1 min-h-0",
        false => ""
      }
  end
end
