# frozen_string_literal: true

class SetupAccountForm < ApplicationForm
  attribute :email_address, :string
  attribute :password, :string
  attribute :password_confirmation, :string

  validates :email_address, presence: true
  validate :passwords_match

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  def self.from(user)
    new(email_address: user.email_address)
  end

  def save(user)
    return false unless valid?

    user.email_address = email_address
    assign_password(user)

    if user.save
      true
    else
      user.errors.each { |error| errors.add(error.attribute, error.message) }
      false
    end
  end

  private def assign_password(user)
    return if password.blank?

    user.password = password
    user.password_confirmation = password_confirmation
  end

  private def passwords_match
    return if password.blank?

    errors.add(:password_confirmation, "doesn't match password") if password != password_confirmation
  end
end
