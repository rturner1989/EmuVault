class SetupCompletionsController < ApplicationController
  skip_before_action :require_setup_complete

  def create
    current_user.update!(setup_completed: true)
    session[:show_onboarding] = true
    redirect_to root_path
  end
end
