# frozen_string_literal: true

module UI
  class LogoComponent < ApplicationComponent
    SIZES = {
      sm: { icon: 24, text: "text-lg" },
      md: { icon: 28, text: "text-xl" },
      lg: { icon: 28, text: "text-2xl" }
    }.freeze

    def initialize(size: :md)
      @config = SIZES.fetch(size.to_sym, SIZES[:md])
    end

    def icon_size
      @config[:icon]
    end

    def text_class
      @config[:text]
    end
  end
end
