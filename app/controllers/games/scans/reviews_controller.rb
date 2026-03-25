module Games
  module Scans
    class ReviewsController < ApplicationController
      def show
        result = current_user.last_scan_result || {}
        @found = result["found"] || []
        @already_in_lib = result["already_in_lib"] || 0
        @skipped_paths = result["skipped_paths"] || []
        @grouped = @found.group_by { |item| item["game_system"] }
      end
    end
  end
end
