# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # Notifications
  def mark_all_read? = true

  # Library scans
  def review? = true
  def confirm? = true

  # Data imports
  def resolve? = true
end
