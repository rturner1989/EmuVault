class EmulatorProfilesController < ApplicationController
  before_action :set_profile, only: %i[edit update destroy]

  def index
    authorize! EmulatorProfile
    @selected_by_system = EmulatorProfile.where(user_selected: true)
      .ordered
      .group_by { |p| p.game_system&.to_sym }
  end

  # step 1: system picker
  def library
    authorize! EmulatorProfile, to: :index?

    selected_systems = EmulatorProfile.where(user_selected: true)
      .distinct
      .pluck(:game_system)
      .compact
      .map(&:to_sym)
    available_systems = EmulatorProfile.where(is_default: true, user_selected: false)
      .distinct
      .pluck(:game_system)
      .compact
      .map(&:to_sym)
    @systems = EmulatorProfile.game_system
      .values
      .select { |v| available_systems.include?(v.value.to_sym) }
    @selected_systems = selected_systems
  end

  # step 2: emulators for a system
  def library_system
    authorize! EmulatorProfile, to: :index?

    systems = Array(params[:systems]).reject(&:blank?)
    @system = params[:system] || systems.first
    @remaining = (systems - [@system])
    @system_label = EmulatorProfile.game_system.find_value(@system)&.text || @system.to_s.upcase
    @profiles = EmulatorProfile.where(is_default: true, user_selected: false, game_system: @system).ordered
    redirect_to library_emulator_profiles_path if @system.blank?
  end

  def add_from_library
    authorize! EmulatorProfile, to: :create?

    selected_ids = (params[:profile_ids] || []).map(&:to_i)
    EmulatorProfile.where(id: selected_ids, is_default: true).update_all(user_selected: true)

    remaining = Array(params[:remaining]).reject(&:blank?)

    if remaining.any?
      redirect_to library_system_emulator_profiles_path(system: remaining.first, remaining: remaining.drop(1))
    else
      redirect_to emulator_profiles_path, notice: "Emulators added."
    end
  end

  def new
    authorize! EmulatorProfile

    @profile = EmulatorProfile.new
  end

  def create
    authorize! EmulatorProfile

    @profile = EmulatorProfile.new(profile_params)
    if @profile.save
      redirect_to emulator_profiles_path, notice: "Profile added."
    else
      render turbo_stream: turbo_stream.replace(dom_id(@profile, :form),
        partial: "emulator_profiles/form",
        locals: { profile: @profile, url: emulator_profiles_path, method: :post, form_id: "new-profile-form" }), status: :unprocessable_entity
    end
  end

  def edit
    authorize! @profile
  end

  def update
    authorize! @profile

    if @profile.update(profile_params)
      redirect_to emulator_profiles_path, notice: "Profile updated."
    else
      render turbo_stream: turbo_stream.replace(dom_id(@profile, :form),
        partial: "emulator_profiles/form",
        locals: { profile: @profile, url: emulator_profile_path(@profile), method: :patch, form_id: "edit-profile-#{@profile.id}-form" }), status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @profile

    if @profile.deletable? && @profile.destroy
      redirect_to emulator_profiles_path, notice: "Profile removed."
    elsif !@profile.deletable?
      @profile.update!(user_selected: false)
      redirect_to emulator_profiles_path, notice: "Profile removed from your list."
    else
      redirect_back_or_to emulator_profiles_path, alert: "Could not remove profile."
    end
  end

  private def set_profile
    @profile = EmulatorProfile.find(params[:id])
  end

  private def profile_params
    params.require(:emulator_profile).permit(:name, :platform, :game_system, :save_extension, :default_save_path, :user_selected)
  end
end
