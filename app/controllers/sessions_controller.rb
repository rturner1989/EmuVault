class SessionsController < ApplicationController
  layout "setup"
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    redirect_to new_registration_path unless User.exists?
  end

  def create
    if (user = User.authenticate_by(session_params))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another username or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private def session_params
    params.require(:session).permit(:username, :password)
  end
end
