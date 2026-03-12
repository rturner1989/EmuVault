# frozen_string_literal: true

class DeviceDecorator < ApplicationDecorator
  DEVICE_TYPE_COLORS = {
    pc: :purple,
    phone: :cyan,
    tablet: :green
  }.freeze

  def type_label
    object.device_type&.text || "Unknown"
  end

  def type_badge_color
    DEVICE_TYPE_COLORS.fetch(object.device_type&.to_sym, :comment)
  end

  def last_seen_label
    return "Never" if object.last_seen_at.nil?

    object.last_seen_at.strftime("%b %-d, %Y at %H:%M")
  end
end
