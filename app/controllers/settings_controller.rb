class SettingsController < ApplicationController
  def show
    authorize! current_user

    @user = current_user
    @scan_paths = ScanPath.ordered
  end

  def update
    authorize! current_user

    @user = current_user
    unless @user.update(scan_params)
      @scan_paths = ScanPath.ordered
      render :show, status: :unprocessable_entity
    end
  end

  private def scan_params
    params.require(:user).permit(:scan_enabled, :scan_interval, :theme, :kuma_url)
  end
end
