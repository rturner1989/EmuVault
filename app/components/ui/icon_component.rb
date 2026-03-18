# frozen_string_literal: true

module UI
  class IconComponent < ApplicationComponent
    def initialize(name:, style: "fa-solid", fw: true, classes: nil)
      @name  = name
      @style = style
      @fw    = fw
      @classes = classes
    end

    def call
      tag.i(class: [ @style, @name, ("fa-fw" if @fw), @classes.presence ].compact.join(" "))
    end
  end
end
