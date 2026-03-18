class SetupController < ApplicationController
  layout "setup"

  # Step 1 — account setup (email + password)
  def show; end

  # Step 1 POST
  def update
    @form = SetupAccountForm.new(setup_account_params)

    if @form.save(current_user)
      redirect_to profiles_setup_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  # Step 2 — pick which emulators you use
  def profiles
    @profiles_by_name = EmulatorProfile.where(is_default: true).ordered.group_by(&:name)
  end

  # Step 2 POST
  def select_profiles
    selected_ids = (params[:profile_ids] || []).map(&:to_i)
    EmulatorProfile.where(is_default: true).update_all(user_selected: false)
    EmulatorProfile.where(id: selected_ids, is_default: true).update_all(user_selected: true)
    redirect_to configure_setup_path
  end

  # Step 3 — configure save directories
  def configure
    @profiles = EmulatorProfile.where(user_selected: true).ordered
    redirect_to profiles_setup_path if @profiles.empty?
  end

  # Step 3 POST — save paths, continue to library step
  def save_configuration
    params[:profiles]&.each do |id, attrs|
      profile = EmulatorProfile.find_by(id: id, user_selected: true)
      profile&.update(default_save_path: attrs[:default_save_path].presence)
    end

    redirect_to library_setup_path
  end

  # Step 4 — configure scan paths + auto-scan
  def library
    @scan_paths = ScanPath.ordered
  end

  # Step 4 POST — save auto-scan settings, mark setup complete
  def save_library
    current_user.update!(
      params.require(:user).permit(:scan_enabled, :scan_interval)
    )
    current_user.update!(setup_completed: true)
    session[:show_onboarding] = true
    redirect_to root_path
  end

  private

  def setup_account_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
