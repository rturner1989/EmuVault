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

    def initialize(id:, title:)
      @id = id
      @title = title
    end
  end
end
