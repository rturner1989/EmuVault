class SetupController < ApplicationController
  layout "setup"

  # Step 1 — account setup (email + password)
  def show; end

  # Step 1 POST
  def update
    user = current_user
    errors = []

    new_email = params.dig(:user, :email_address).presence
    new_password = params.dig(:user, :password).presence
    password_confirmation = params.dig(:user, :password_confirmation).presence

    if new_email
      user.email_address = new_email
    end

    if new_password.present?
      if new_password != password_confirmation
        errors << "Password confirmation doesn't match"
      else
        user.password = new_password
        user.password_confirmation = password_confirmation
      end
    end

    if errors.any? || !user.save
      @errors = errors + user.errors.full_messages
      render :show, status: :unprocessable_entity
    else
      redirect_to profiles_setup_path
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

    if Game.exists?
      redirect_to games_path, notice: "Setup complete!"
    else
      redirect_to new_game_path, notice: "Setup complete! Add your first game."
    end
  end
end
