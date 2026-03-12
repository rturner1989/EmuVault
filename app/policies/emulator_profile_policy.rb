# frozen_string_literal: true

class EmulatorProfilePolicy < ApplicationPolicy
  def destroy? = false
  def create?  = false
  def update?  = false
end
