# frozen_string_literal: true

module Layouts
  class FlashComponent < ApplicationComponent
    VARIANT_CLASSES = {
      notice: "bg-drac-green/10 border-drac-green text-drac-green",
      alert: "bg-drac-red/10 border-drac-red text-drac-red"
    }.freeze

    def initialize(flash:)
      @flash = flash
    end

    def messages
      @flash.map { |type, message| [ type.to_sym, message ] }
            .select { |type, _| VARIANT_CLASSES.key?(type) }
    end

    def variant_class(type)
      VARIANT_CLASSES.fetch(type, VARIANT_CLASSES[:notice])
    end
  end
end
