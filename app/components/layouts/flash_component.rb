# frozen_string_literal: true

module Layouts
  class FlashComponent < ApplicationComponent
    BASE = "fixed space-y-2 flash-container z-[60] pointer-events-none top-4 left-4 right-4 lg:left-auto lg:right-4 lg:w-80"

    def initialize(flash:, position: :top)
      @flash = flash
      @kwargs = {
        id: "flash-container",
        class: position == :bottom ? "#{BASE} flash-container--bottom" : BASE
      }
    end
  end
end
