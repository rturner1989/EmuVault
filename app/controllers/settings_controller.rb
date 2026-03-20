class SettingsController < ApplicationController
  def show
    authorize! current_user

    @user = Current.user
    @scan_paths = ScanPath.ordered
  end

  def update
    authorize! current_user

    @user = Current.user
    if @user.update(scan_params)
    else
      render :show, status: :unprocessable_entity
    end
  end

  private def scan_params
    params.require(:user).permit(:scan_enabled, :scan_interval, :theme)
  end
end
