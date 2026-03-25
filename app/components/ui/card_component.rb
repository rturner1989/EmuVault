# frozen_string_literal: true

module UI
  class CardComponent < ApplicationComponent
    renders_one :header
    renders_one :footer
    renders_one :body
    renders_many :footer_actions, "UI::ActionComponent"

    PADDING = {
      sm: "px-4 py-3",
      md: "px-5 py-4"
    }.freeze

    def initialize(padding: :md, scrollable: false, **kwargs)
      @padding = padding.to_sym
      @scrollable = scrollable
      extra_class = kwargs.delete(:class)
      classes = [
        "rounded-lg overflow-hidden bg-base-100 border border-base-300",
        ("flex flex-col min-h-0" if scrollable),
        extra_class
      ].compact.reject(&:empty?).join(" ")
      @kwargs = kwargs.merge(class: classes)
    end

    def padding_class
      PADDING[@padding]
    end

    def content_class
      @scrollable ? "overflow-y-auto flex-1 min-h-0" : nil
    end

    def body_class
      [
        ("overflow-y-auto flex-1 min-h-0" if @scrollable),
        padding_class
      ].compact.reject(&:empty?).join(" ")
    end
  end
end
