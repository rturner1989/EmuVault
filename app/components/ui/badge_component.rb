# frozen_string_literal: true

module UI
  class BadgeComponent < ApplicationComponent
    COLOR_CLASSES = {
      purple: "bg-drac-purple/20 text-drac-purple",
      green: "bg-drac-green/20 text-drac-green",
      cyan: "bg-drac-cyan/20 text-drac-cyan",
      yellow: "bg-drac-yellow/20 text-drac-yellow",
      pink: "bg-drac-pink/20 text-drac-pink",
      orange: "bg-drac-orange/20 text-drac-orange",
      red: "bg-drac-red/20 text-drac-red",
      comment: "bg-drac-comment/20 text-drac-comment"
    }.freeze

    def initialize(label:, color: :comment)
      @label = label
      @color = color.to_sym
    end

    def color_class
      COLOR_CLASSES.fetch(@color, COLOR_CLASSES[:comment])
    end
  end
end
