# frozen_string_literal: true

module Layouts
  class FlashComponent < ApplicationComponent
    def initialize(flash:)
      @flash = flash
      @kwargs = { 
        id: "flash-container", 
        class: "fixed space-y-2 flash-container z-[60] left-4 right-4 lg:top-4 lg:left-auto lg:right-4 lg:w-80"
      }
    end
  end
end
