# frozen_string_literal: true

module UI
  class ConfirmComponent < ApplicationComponent
    def initialize(id:, title:, message:, url:, method: :delete, trigger_label: "Remove", confirm_label: "Confirm", size: :sm, params: {}, trigger_variant: :danger, trigger_icon: nil, trigger_class: nil)
      @id = id
      @title = title
      @message = message
      @url = url
      @method = method
      @trigger_label = trigger_label
      @confirm_label = confirm_label
      @size = size
      @params = params
      @trigger_variant = trigger_variant
      @trigger_icon = trigger_icon
      @trigger_class = trigger_class
    end
  end
end
