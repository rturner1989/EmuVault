module Games
  class ScansController < ApplicationController
    def create
      if setup_incomplete?
        result = GameScanJob.perform_now("auto_all")
        added = result["added"] || 0
        message = added > 0 ? "#{added} #{"game".pluralize(added)} imported." : "No new games found."
        redirect_to games_path, notice: message
      else
        GameScanJob.perform_now("dry_run")
        redirect_to game_scan_review_path
      end
    end
  end
end
