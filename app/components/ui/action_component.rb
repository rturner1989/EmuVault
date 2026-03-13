# frozen_string_literal: true

module UI
  class ActionComponent < ApplicationComponent
    VARIANTS = {
      primary: "rounded-lg bg-drac-purple px-4 py-2 text-sm font-medium text-drac-bg hover:opacity-90 active:opacity-70 transition-opacity cursor-pointer",
      secondary: "rounded-lg border border-drac-current px-4 py-2 text-sm text-drac-comment hover:border-drac-fg hover:text-drac-fg transition-colors cursor-pointer"
    }.freeze

    def initialize(label:, href: nil, variant: :secondary, **html_options)
      @label = label
      @href = href
      @html_options = html_options.merge(class: VARIANTS.fetch(variant.to_sym))
    end
  end
end
