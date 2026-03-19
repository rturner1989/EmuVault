# frozen_string_literal: true

class SetupSystemsForm < ApplicationForm
  attr_accessor :system_keys

  validate :at_least_one_system

  def self.model_name
    ActiveModel::Name.new(self, nil, "Setup")
  end

  def initialize(attrs = {})
    super()
    @system_keys = Array(attrs[:system_keys]).reject(&:blank?)
  end

  def save
    return false unless valid?

    # Deselect profiles for unchecked systems
    EmulatorProfile.where(is_default: true)
                   .where.not(game_system: system_keys)
                   .update_all(user_selected: false)

    true
  end

  private def at_least_one_system
    errors.add(:base, "Please select at least one system") if system_keys.empty?
  end
end
