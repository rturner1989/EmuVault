# frozen_string_literal: true

module Layouts
  class FlashComponent < ApplicationComponent
    def initialize(flash:)
      @flash = flash
    end
  end
end
