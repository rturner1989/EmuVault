# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  # Single-user app — any authenticated user may perform any action.
  def index?   = true
  def show?    = true
  def new?     = true
  def create?  = true
  def edit?    = true
  def update?  = true
  def destroy? = true
end
