class EmulatorProfilesController < ApplicationController
  before_action :set_profile, only: %i[edit update destroy]

  def index
    @selected_by_system = EmulatorProfile.where(user_selected: true)
      .ordered
      .group_by { |p| p.game_system&.to_sym }
  end

  def new
    @profile = EmulatorProfile.new
  end

  def create
    @profile = EmulatorProfile.new(profile_params.merge(user_selected: true))
    if @profile.save
      load_profiles_list
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      load_profiles_list
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @profile.in_use?
      @destroy_failed = true
      @destroy_error = :in_use
      return
    end

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
