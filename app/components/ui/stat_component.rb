# frozen_string_literal: true

module UI
  class StatComponent < ApplicationComponent
    renders_one :icon, "UI::IconComponent"
    renders_one :action, ->(href:, label: "View all", icon: "fa-arrow-right", **kwargs) {
      component = ActionComponent.new(href: href, variant: :link_primary, class: "text-xs", **kwargs)
      component.with_trailing_icon(name: icon)
      component.with_content(label)
      component
    }

    def initialize(title:, value:, description: nil, value_color: nil)
      @title = title
      @value = value
      @description = description
      @value_color = value_color
    end
  end
end
