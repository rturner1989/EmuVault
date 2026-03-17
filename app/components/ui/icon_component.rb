# frozen_string_literal: true

module UI
  class IconComponent < ApplicationComponent
    def initialize(name:, style: "fa-solid", fw: true)
      @name  = name
      @style = style
      @fw    = fw
    end

    def call
      tag.i(class: [ @style, @name, ("fa-fw" if @fw) ].compact.join(" "))
    end
  end
end
