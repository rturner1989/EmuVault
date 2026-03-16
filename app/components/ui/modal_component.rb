# frozen_string_literal: true

module UI
  class ModalComponent < ApplicationComponent
    renders_one :trigger
    # renders_one :trigger, lambda { |label: nil, **kwargs|
    #   args = kwargs.merge({ label: label, data: { action: "dialog#open" }})
    #   UI::ActionComponent.new(**args)
    # }
    renders_one :body
    renders_one :page_content

    def initialize(id:, title:, variant: :default)
      @id = id
      @title = title
      @variant = variant
    end

    def content_classes
      base = "dialog-content"
      @variant == :bottom_sheet ? "#{base} dialog-content--bottom" : base
    end
  end
end
