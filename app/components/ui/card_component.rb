# frozen_string_literal: true

module UI
  class CardComponent < ApplicationComponent
    renders_one :header
    renders_one :footer
    renders_one :body
    renders_many :footer_actions, "UI::ActionComponent"

    PADDINGS = {
      sm: "px-4 py-3",
      md: "px-5 py-4"
    }.freeze

    def initialize(padding: :md, scrollable: false, **html_options)
      @padding = PADDINGS.fetch(padding.to_sym, PADDINGS[:md])
      @scrollable = scrollable
      extra_class = html_options.delete(:class)
      base_class = "rounded-lg overflow-hidden bg-base-100 border border-base-300"
      base_class = "#{base_class} flex flex-col min-h-0" if scrollable
      @class = extra_class ? "#{base_class} #{extra_class}" : base_class
      @html_options = html_options
    end

    def content_class
      @scrollable ? "overflow-y-auto flex-1 min-h-0" : nil
    end

    def body_class
      classes = [ @padding ]
      classes << "overflow-y-auto flex-1 min-h-0" if @scrollable
      classes.join(" ")
    end
  end
end
