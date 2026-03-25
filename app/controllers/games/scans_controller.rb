module Games
  class ScansController < MainController
    def create
      GameScanJob.perform_now("dry_run")
      redirect_to game_scan_review_path
    end
  end
end
