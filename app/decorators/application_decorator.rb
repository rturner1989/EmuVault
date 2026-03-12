# frozen_string_literal: true

class ApplicationDecorator < SimpleDelegator
  def self.decorate(record_or_collection)
    if record_or_collection.respond_to?(:map)
      record_or_collection.map { |r| new(r) }
    else
      new(record_or_collection)
    end
  end

  def object
    __getobj__
  end
end
