class EmulatorProfilesController < ApplicationController
  def index
    authorize! EmulatorProfile
    @profiles_by_name = EmulatorProfile.order(:name, :platform).group_by(&:name)
  end
end
