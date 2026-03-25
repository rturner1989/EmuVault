module SetupProgress
  extend ActiveSupport::Concern

  included do
    helper_method :setup_total_steps, :setup_incomplete?
  end

  private def next_setup_step_path
    return emulator_profiles_path unless EmulatorProfile.where(user_selected: true).exists?
    return games_path unless Game.exists?

    nil
  end

  private def setup_total_steps
    2
  end

  private def setup_incomplete?
    current_user && !current_user.setup_completed?
  end
end
