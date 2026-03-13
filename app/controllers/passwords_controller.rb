class PasswordsController < ApplicationController
  def edit
  end

  def update
    if Current.user.authenticate(params[:current_password])
      if Current.user.update(params.permit(:password, :password_confirmation))
        redirect_to settings_path, notice: "Password updated."
      else
        redirect_to settings_path, alert: "New passwords did not match."
      end
    else
      redirect_to settings_path, alert: "Current password is incorrect."
    end
  end
end
