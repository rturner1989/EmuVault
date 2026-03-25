module Onboarding
  class StepController < OnboardingController
    before_action :require_setup_incomplete

    private def require_setup_incomplete
      redirect_to root_path if current_user.setup_completed?
    end
  end
end
