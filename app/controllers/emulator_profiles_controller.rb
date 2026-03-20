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
    visible_systems = (selected_systems + available_systems).uniq
    @systems = EmulatorProfile.game_system
      .values
      .select { |v| visible_systems.include?(v.value.to_sym) }
    @selected_systems = selected_systems
  end

  # step 2: emulators for a system
  def library_system
    authorize! EmulatorProfile, to: :index?

    if params[:system].present?
      @system = params[:system]
      @remaining = Array(params[:remaining]).reject(&:blank?)
      @total = params[:total].to_i
    else
      systems = Array(params[:systems]).reject(&:blank?)
      @system = systems.first
      @remaining = systems.drop(1)
      @total = systems.size
    end
    @current_pos = @total - @remaining.size
    @system_label = EmulatorProfile.game_system.find_value(@system)&.text || @system.to_s.upcase
    @profiles = EmulatorProfile.where(is_default: true, user_selected: false, game_system: @system).ordered

    return redirect_to library_emulator_profiles_path if @system.blank?
  end

  def add_from_library
    authorize! EmulatorProfile, to: :create?

    selected_ids = (params[:profile_ids] || []).map(&:to_i)
    EmulatorProfile.where(id: selected_ids, is_default: true).update_all(user_selected: true)

    remaining = Array(params[:remaining]).reject(&:blank?)

    if remaining.any?
      redirect_to library_system_emulator_profiles_path(system: remaining.first, remaining: remaining.drop(1), total: params[:total])
    else
      load_profiles_list
    end
  end

  def new
    authorize! EmulatorProfile

    @profile = EmulatorProfile.new
  end

  def create
    authorize! EmulatorProfile

    @profile = EmulatorProfile.new(profile_params.merge(user_selected: true))
    if @profile.save
      load_profiles_list
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! @profile
  end

  def update
    authorize! @profile

    if @profile.update(profile_params)
      load_profiles_list
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @profile

    if @profile.deletable? && !@profile.destroy
      @destroy_failed = true
      return
    end

    unless @profile.deletable?
      @profile.update!(user_selected: false)
    end

    @notice_text = @profile.deletable? ? "Profile removed." : "Profile removed from your list."
    load_profiles_list
  end

  private def load_profiles_list
    @selected_by_system = EmulatorProfile.where(user_selected: true)
      .ordered
      .group_by { |p| p.game_system&.to_sym }
  end

  private def set_profile
    @profile = EmulatorProfile.find(params[:id])
  end

  private def profile_params
    params.require(:emulator_profile).permit(:name, :platform, :game_system, :save_extension, :default_save_path)
  end
end
