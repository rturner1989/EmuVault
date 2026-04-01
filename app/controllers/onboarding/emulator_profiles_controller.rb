module Onboarding
  class EmulatorProfilesController < StepController
    def index
      @selected_by_system = EmulatorProfile.selected_by_system
      @in_use_systems = Game.systems_in_use
    end
  end
end
