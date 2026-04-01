module Games
  module Scans
    class ConfirmationsController < MainController
      include ActionView::Helpers::TextHelper

      def create
        selected_roms = Set.new(params[:selected_roms] || [])
        scan_result = current_user.last_scan_result || {}
        stored = scan_result.dig("found") || []
        items = stored.select { |item| selected_roms.include?(item["rom_path"]) }

        current_user.update!(last_scan_result: scan_result.merge("status" => "reviewed"))

        if items.any?
          GameScanConfirmJob.perform_later(items, user_id: current_user.id)
          @notice_text = "#{pluralize(items.size, "game")} queued for import."
        else
          @alert_text = "No games selected."
        end
      end
    end
  end
end
