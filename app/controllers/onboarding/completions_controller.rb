module Onboarding
  class CompletionsController < StepController
    def create
      current_user.update!(setup_completed: true)
      session[:show_onboarding] = true
      redirect_to root_path
    end
  end
end
