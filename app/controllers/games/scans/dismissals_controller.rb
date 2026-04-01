# frozen_string_literal: true

module Games
  module Scans
    class DismissalsController < MainController
      def create
        scan_result = current_user.last_scan_result
        current_user.update!(last_scan_result: scan_result.merge("status" => "reviewed")) if scan_result

        redirect_to games_path, status: :see_other
      end
    end
  end
end
