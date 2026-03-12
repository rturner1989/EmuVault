# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attr_accessor :id

  def persisted?
    id.present?
  end

  def to_key
    persisted? ? [ id ] : nil
  end

  def to_param
    id&.to_s
  end

  # Build a form pre-populated from an existing AR record
  def self.from(record)
    attrs = record.attributes.slice(*attribute_names.map(&:to_s)).symbolize_keys
    form = new(**attrs)
    form.id = record.id
    form
  end

  # Validate and persist attributes onto an AR record
  def persist(record)
    return false unless valid?

    record.assign_attributes(form_attributes)
    record.save
  end

  private

  def form_attributes
    self.class.attribute_names.each_with_object({}) do |name, hash|
      hash[name] = public_send(name)
    end
  end
end
