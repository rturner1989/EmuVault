class RegistrationsController < ApplicationController
  layout "setup"
  allow_unauthenticated_access
  before_action :require_no_users

  def new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to setup_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def registration_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  private def require_no_users
    redirect_to root_path if User.exists?
  end
end
