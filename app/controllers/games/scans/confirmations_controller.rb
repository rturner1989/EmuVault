module Games
  module Scans
    class ConfirmationsController < ApplicationController
      include ActionView::Helpers::TextHelper

      def create
        selected_roms = Set.new(params[:selected_roms] || [])
        stored = current_user.last_scan_result&.dig("found") || []
        items = stored.select { |item| selected_roms.include?(item["rom_path"]) }

        if items.any?
          GameScanJob.perform_later("confirm", items)
          redirect_to games_path, notice: "#{items.size} #{pluralize(items.size, "game")} queued for import — they'll appear in your library shortly."
        else
          redirect_to game_scan_review_path, alert: "No games selected."
        end
      end
    end
  end
end
