module Games
  module Scans
    class ConfirmationsController < MainController
      include ActionView::Helpers::TextHelper

      def create
        selected_roms = Set.new(params[:selected_roms] || [])
        stored = current_user.last_scan_result&.dig("found") || []
        items = stored.select { |item| selected_roms.include?(item["rom_path"]) }

        if items.any?
          GameScanJob.perform_later("confirm", items)
          @notice_text = "#{pluralize(items.size, "game")} queued for import."
        else
          @alert_text = "No games selected."
        end
      end
    end
  end
end
