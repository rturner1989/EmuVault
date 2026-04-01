module Games
  class ScansController < MainController
    def create
      GameScanDryRunJob.perform_later(user_id: current_user.id)
    end
  end
end
