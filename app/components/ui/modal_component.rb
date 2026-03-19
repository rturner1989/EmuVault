# frozen_string_literal: true

module UI
  class ModalComponent < ApplicationComponent
    renders_one :trigger
    renders_one :body
    renders_one :footer
    renders_many :footer_actions, "UI::ActionComponent"
    renders_one :page_content

    def initialize(id:, title:, subtitle: nil, variant: :default, container_data: {})
      @id = id
      @title = title
      @subtitle = subtitle
      @variant = variant
      @container_data = container_data
    end

    def managed?
      @container_data.empty?
    end

    def content_classes
      base = "dialog-content"
      @variant == :bottom_sheet ? "#{base} dialog-content--bottom" : base
    end
  end
end
