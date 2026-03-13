class SettingsController < ApplicationController
  def show
    @user = Current.user
  end
end
