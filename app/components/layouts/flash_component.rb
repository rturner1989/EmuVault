# frozen_string_literal: true

module Layouts
  class FlashComponent < ApplicationComponent
    def initialize(flash:)
      @flash = flash
    end

    class Item < ApplicationComponent
      VARIANTS = {
        notice: { css: "alert-success", icon: "fa-circle-check" },
        alert: { css: "alert-error",   icon: "fa-circle-xmark" },
        info: { css: "alert-info",    icon: "fa-circle-info" },
        warning: { css: "alert-warning", icon: "fa-triangle-exclamation" }
      }.freeze

      def initialize(type:, message:)
        @type = type.to_sym
        @message = message
      end

      def variant
        VARIANTS.fetch(@type, VARIANTS[:notice])
      end

      def call
        tag.div(role: "alert", class: "alert #{variant[:css]} shadow-lg overflow-hidden relative",
          data: { controller: "flash", flash_duration_value: "4000" }) do
          safe_join([
            tag.i(class: "fa-solid #{variant[:icon]} fa-fw shrink-0"),
            tag.span(@message, class: "flex-1 text-sm"),
            tag.button(class: "btn btn-ghost btn-sm btn-circle shrink-0", "aria-label": "Dismiss",
              data: { action: "flash#dismiss" }) do
              tag.i(class: "fa-solid fa-xmark fa-fw")
            end,
            tag.div(class: "flash-progress", data: { flash_target: "progress" })
          ])
        end
      end
    end
  end
end
