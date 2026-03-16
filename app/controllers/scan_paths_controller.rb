class ScanPathsController < ApplicationController
  before_action :set_scan_path, only: %i[update destroy]

  def create
    @scan_path = ScanPath.new(scan_path_params)
    if @scan_path.save
      redirect_back_or_to settings_path
    else
      redirect_back_or_to settings_path, alert: @scan_path.errors.full_messages.to_sentence
    end
  end

  def update
    if @scan_path.update(scan_path_params)
      redirect_back_or_to settings_path
    else
      redirect_back_or_to settings_path, alert: @scan_path.errors.full_messages.to_sentence
    end
  end

  def destroy
    @scan_path.destroy
    redirect_back_or_to settings_path
  end

  private

  def set_scan_path
    @scan_path = ScanPath.find(params[:id])
  end

  def scan_path_params
    params.require(:scan_path).permit(:path, :game_system, :auto_scan)
  end
end
