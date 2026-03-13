# frozen_string_literal: true

module UI
  class FilterSelectComponent < ApplicationComponent
    def initialize(url:, param:, options:, selected:, clear_url:, turbo_frame: nil)
      @url = url
      @param = param
      @options = options
      @selected = selected
      @clear_url = clear_url
      @turbo_frame = turbo_frame
    end

    def form_data
      data = { controller: "auto-submit" }
      data[:turbo_frame] = @turbo_frame if @turbo_frame
      data
    end

    def clear_data
      return {} unless @turbo_frame

      { turbo_frame: @turbo_frame }
    end
  end
end
