# frozen_string_literal: true

class GameScanDryRunJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    user = User.find(user_id)
    result = GameScanner.new.collect(ScanPath.ordered)
    result["status"] = "reviewed"
    user.update!(last_scan_result: result)

    broadcast_dry_run_complete(user, result)
  end

  private def broadcast_dry_run_complete(user, result)
    found = result["found"] || []
    already_in_lib = result["already_in_lib"] || 0
    skipped_paths = result["skipped_paths"] || []
    grouped = found.group_by { |item| item["game_system"] }

    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "scan-review-content",
      html: ApplicationController.render(
        partial: "games/scans/review_content",
        locals: { found: found, already_in_lib: already_in_lib, skipped_paths: skipped_paths, grouped: grouped }
      )
    )
  end
end
