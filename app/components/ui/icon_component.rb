# frozen_string_literal: true

module UI
  class IconComponent < ApplicationComponent
    def initialize(name:, style: "fa-solid", fw: true, **kwargs)
      extra = kwargs.delete(:class)
      @kwargs = kwargs.merge(class: [style, name, ("fa-fw" if fw), extra].compact.join(" "))
    end

    def call
      tag.i(**@kwargs)
    end
  end
end
