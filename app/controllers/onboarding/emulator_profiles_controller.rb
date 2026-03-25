module Onboarding
  class EmulatorProfilesController < StepController
    def index
      @selected_by_system = EmulatorProfile.where(user_selected: true)
        .ordered
        .group_by { |p| p.game_system&.to_sym }
    end
  end
end
