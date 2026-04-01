# frozen_string_literal: true

class GameScanConfirmJob < ApplicationJob
  include ScanBroadcasting
  queue_as :default

  def perform(items, user_id:)
    user = User.find(user_id)

    broadcast_scan_start(user)
    result = GameScanner.new.import_items(items) { |game| broadcast_game_added(user, game) }
    result["status"] = "completed"
    user.update!(last_scanned_at: Time.current, last_scan_result: result)
    broadcast_import_complete(user, result)
  end
end
