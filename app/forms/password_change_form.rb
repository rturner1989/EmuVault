# frozen_string_literal: true

class PasswordChangeForm < ApplicationForm
  attribute :current_password, :string
  attribute :password, :string
  attribute :password_confirmation, :string

  validates :current_password, presence: true
  validates :password, presence: true
  validate :passwords_match

  def self.model_name
    ActiveModel::Name.new(self, nil, "Password")
  end

  def save(user)
    return false unless valid?

    unless user.authenticate(current_password)
      errors.add(:current_password, "is incorrect")
      return false
    end

    if user.update(password: password, password_confirmation: password_confirmation)
      true
    else
      user.errors.each { |error| errors.add(error.attribute, error.message) }
      false
    end
  end

  private

  def passwords_match
    return if password.blank?

    errors.add(:password_confirmation, "doesn't match password") if password != password_confirmation
  end
end
