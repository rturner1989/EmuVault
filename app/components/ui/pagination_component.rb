# frozen_string_literal: true

module UI
  class PaginationComponent < ApplicationComponent
    def initialize(pagy:, base_path:, params: {})
      @pagy = pagy
      @base_path = base_path
      @params = params.compact
    end

    def render?
      @pagy.pages > 1
    end

    def page_url(page)
      "#{@base_path}?#{@params.merge(page: page).to_query}"
    end
  end
end
