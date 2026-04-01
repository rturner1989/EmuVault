module Onboarding
  class ScansController < StepController
    def create
      GameScanImportAllJob.perform_later(user_id: current_user.id)
    end
  end
end
