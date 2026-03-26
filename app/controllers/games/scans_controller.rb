module Games
  class ScansController < MainController
    def create
      GameScanJob.perform_later("dry_run")
    end
  end
end
