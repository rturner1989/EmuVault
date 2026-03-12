class SettingsController < ApplicationController
  def show
    @user = Current.user
  end

  def regenerate_token
    Current.user.regenerate_api_token!
    redirect_to settings_path, notice: "API token regenerated."
  end
end
