class EmulatorProfilesController < ApplicationController
  before_action :set_profile, only: %i[edit update destroy]

  def index
    authorize! EmulatorProfile
    @selected_profiles = EmulatorProfile.where(user_selected: true).ordered
    @library_by_name = EmulatorProfile.where(is_default: true, user_selected: false).ordered.group_by(&:name)
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
      render :new, status: :unprocessable_entity
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
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @profile
    if @profile.deletable?
      @profile.destroy
      redirect_to emulator_profiles_path, notice: "Profile removed."
    else
      # Default profiles can be deselected but not deleted
      @profile.update!(user_selected: false)
      redirect_to emulator_profiles_path, notice: "Profile removed from your list."
    end
  end

  private

  def set_profile
    @profile = EmulatorProfile.find(params[:id])
  end

  def profile_params
    params.require(:emulator_profile).permit(:name, :platform, :save_extension, :default_save_path, :user_selected)
  end
end
