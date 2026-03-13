# frozen_string_literal: true

module UI
  class ConfirmComponent < ApplicationComponent
    def initialize(id:, title:, message:, url:, method: :delete, trigger_label: "Remove", confirm_label: "Confirm")
      @id = id
      @title = title
      @message = message
      @url = url
      @method = method
      @trigger_label = trigger_label
      @confirm_label = confirm_label
    end
  end
end
