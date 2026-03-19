# frozen_string_literal: true

module UI
  class StatComponent < ApplicationComponent
    renders_one :icon, "UI::IconComponent"
    renders_one :action

    def initialize(title:, value:, description: nil, value_color: nil)
      @title = title
      @value = value
      @description = description
      @value_color = value_color
    end
  end
end
