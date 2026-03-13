class ApplicationController < ActionController::Base
  include Authentication
  include ActionPolicy::Behaviour

  allow_browser versions: :modern

  helper_method :current_user

  before_action :require_setup_complete

  private

  def current_user
    Current.user
  end

  def require_setup_complete
    return unless current_user
    return if current_user.setup_completed?
    return if controller_name == "setup" || controller_name == "sessions" || controller_name == "passwords"

    redirect_to setup_path
  end
end
