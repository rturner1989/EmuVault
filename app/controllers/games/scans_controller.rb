module Games
  class ScansController < MainController
    def create
      GameScanJob.perform_later("dry_run", user_id: current_user.id)
    end
  end
end
