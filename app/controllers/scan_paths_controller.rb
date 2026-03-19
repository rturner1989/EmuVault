class ScanPathsController < ApplicationController
  before_action :set_scan_path, only: %i[update destroy]

  def create
    authorize! ScanPath

    @scan_path = ScanPath.new(scan_path_params)
    if @scan_path.save
      redirect_to fallback_path
    else
      redirect_to fallback_path, alert: @scan_path.errors.full_messages.to_sentence
    end
  end

  def update
    authorize! @scan_path

    if @scan_path.update(scan_path_params)
      redirect_to fallback_path
    else
      redirect_to fallback_path, alert: @scan_path.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize! @scan_path

    @scan_path.destroy
    redirect_to fallback_path
  end

  private def fallback_path
    current_user.setup_completed? ? settings_path : library_setup_path
  end

  private def set_scan_path
    @scan_path = ScanPath.find(params[:id])
  end

  private def scan_path_params
    params.require(:scan_path).permit(:path, :game_system, :auto_scan)
  end
end
