module Onboarding
  class ScansController < StepController
    def create
      result = GameScanJob.perform_now("auto_all")
      added = result["added"] || 0
      message = added > 0 ? "#{added} #{"game".pluralize(added)} imported." : "No new games found."
      redirect_to onboarding_games_path, notice: message
    end
  end
end
