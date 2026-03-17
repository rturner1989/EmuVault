# frozen_string_literal: true

module Layouts
  class FlashItemComponent < ApplicationComponent
    VARIANTS = {
      notice: { css: "alert-success", icon: "fa-circle-check" },
      alert:  { css: "alert-error",   icon: "fa-circle-xmark" },
      info:   { css: "alert-info",    icon: "fa-circle-info"  },
      warning: { css: "alert-warning", icon: "fa-triangle-exclamation" }
    }.freeze

    def initialize(type:, message:)
      @type    = type.to_sym
      @message = message
    end

    def variant
      VARIANTS.fetch(@type, VARIANTS[:notice])
    end
  end
end
