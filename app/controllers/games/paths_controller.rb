module Games
  class PathsController < ApplicationController
    before_action :set_scan_path, only: %i[update destroy]
    before_action :load_available_systems

    def create
      @scan_path = ScanPath.new(scan_path_params)
      if @scan_path.save
        return redirect_to settings_path unless turbo_frame_request?

        @scan_paths = ScanPath.ordered
        @notice_text = "Scan path added."
      else
        redirect_to settings_path, alert: @scan_path.errors.full_messages.to_sentence
      end
    end

    def update
      if @scan_path.update(scan_path_params)
        return redirect_to settings_path unless turbo_frame_request?

        @scan_paths = ScanPath.ordered
        @notice_text = "Scan path updated."
      else
        redirect_to settings_path, alert: @scan_path.errors.full_messages.to_sentence
      end
    end

    def destroy
      if @scan_path.destroy
        return redirect_to settings_path unless turbo_frame_request?

        @scan_paths = ScanPath.ordered
        @notice_text = "Scan path removed."
      else
        redirect_to settings_path, alert: "Could not remove scan path."
      end
    end

    private def load_available_systems
      @available_systems = EmulatorProfile.where(user_selected: true).distinct.pluck(:game_system).compact
    end

    private def set_scan_path
      @scan_path = ScanPath.find(params[:id])
    end

    private def scan_path_params
      params.require(:scan_path).permit(:path, :game_system, :auto_scan)
    end
  end
end
