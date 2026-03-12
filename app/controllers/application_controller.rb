class ApplicationController < ActionController::Base
  include Authentication
  include ActionPolicy::Behaviour

  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    Current.user
  end
end
