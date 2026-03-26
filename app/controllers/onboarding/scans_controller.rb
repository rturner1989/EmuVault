module Onboarding
  class ScansController < StepController
    def create
      GameScanJob.perform_later("auto_all")
    end
  end
end
