# frozen_string_literal: true

class DeviceForm < ApplicationForm
  attribute :name, :string
  attribute :device_type, :string
  attribute :identifier, :string

  validates :name, presence: true
  validates :device_type, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "Device")
  end
end
