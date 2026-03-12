# frozen_string_literal: true

module UI
  class EmptyStateComponent < ApplicationComponent
    renders_one :action

    def initialize(title:, description: nil)
      @title = title
      @description = description
    end
  end
end
