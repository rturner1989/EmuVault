# frozen_string_literal: true

module UI
  class ModalComponent < ApplicationComponent
    renders_one :trigger
    renders_one :body

    def initialize(id:, title:)
      @id = id
      @title = title
    end
  end
end
