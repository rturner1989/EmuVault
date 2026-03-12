# frozen_string_literal: true

module UI
  class PageHeaderComponent < ApplicationComponent
    renders_many :actions

    def initialize(title:, subtitle: nil)
      @title = title
      @subtitle = subtitle
    end
  end
end
