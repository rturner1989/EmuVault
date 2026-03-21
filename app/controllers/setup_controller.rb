class SetupController < ApplicationController
  layout "setup"
  before_action :redirect_if_setup_complete

  # Redirect to first step (emulator profiles)
  def show
    redirect_to profiles_setup_path
  end

  # Step 1a — system picker (or emulator picker when ?system= is present, handled in view)
  def profiles
    session.delete(:pending_systems) unless params[:system].present?
  end

  # Step 1a POST — save selected systems, auto-select their profiles, begin per-system emulator config
  def select_systems
    @form = SetupSystemsForm.new(system_keys: params[:system_keys])

    if @form.save
      session[:pending_systems] = @form.system_keys
      redirect_to profiles_setup_path(system: @form.system_keys.first)
    else
      redirect_to profiles_setup_path, alert: @form.errors.full_messages.first
    end
  end

  # Step 1b POST — save emulator selections for a specific system, advance to next system or step 2
  def select_profiles
    system_key = params[:redirect_system].presence
    selected_ids = (params[:profile_ids] || []).map(&:to_i)

    if system_key
      system_profiles = EmulatorProfile.where(is_default: true, game_system: system_key)
      system_profiles.update_all(user_selected: false)
      EmulatorProfile.where(id: selected_ids, is_default: true, game_system: system_key)
                     .update_all(user_selected: true)

      # Advance to next system in queue, or step 2
      pending = Array(session[:pending_systems])
      current_index = pending.index(system_key)
      next_system = current_index ? pending[current_index + 1] : nil

      if next_system
        redirect_to profiles_setup_path(system: next_system)
      else
        session.delete(:pending_systems)
        redirect_to configure_setup_path
      end
    else
      redirect_to configure_setup_path
    end
  end

  # Step 2 — configure save directories (one row per emulator+platform, not per system)
  def configure
    # Group selected profiles by name+platform so the user sets one path per
    # emulator installation, not one per system (e.g. RetroArch Linux shows once)
    @profiles_by_emulator = EmulatorProfile.where(user_selected: true)
                                           .ordered
                                           .group_by { |p| [ p.name, p.platform.to_sym ] }
    redirect_to profiles_setup_path if @profiles_by_emulator.empty?
  end

  # Step 2 POST — save paths (apply to all profiles for the same emulator+platform)
  def save_configuration
    params[:emulators]&.each do |key, attrs|
      name, platform = key.split("|")
      path = attrs[:default_save_path].presence
      EmulatorProfile.where(name: name, platform: platform, user_selected: true)
                     .update_all(default_save_path: path)
    end

    redirect_to library_setup_path
  end

  # Step 3 — configure scan paths + auto-scan
  def library
    @scan_paths = ScanPath.ordered
  end

  # Step 3 POST — save auto-scan settings, mark setup complete
  def save_library
    current_user.update!(
      params.require(:user).permit(:scan_enabled, :scan_interval)
    )
    current_user.update!(setup_completed: true)
    session[:show_onboarding] = true
    redirect_to root_path
  end

  private def redirect_if_setup_complete
    redirect_to root_path, notice: "Setup is already complete." if current_user&.setup_completed?
  end
end
