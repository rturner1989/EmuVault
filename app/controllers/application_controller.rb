class ApplicationController < ActionController::Base
  include Authentication
  include ActionPolicy::Behaviour
  include SetupProgress

  allow_browser versions: :modern

  before_action :require_setup_complete
  before_action :load_onboarding_flag
  before_action :load_quick_sync_data
  before_action :load_available_systems

  private def load_onboarding_flag
    @show_onboarding = session.delete(:show_onboarding).present?
  end

  private def load_available_systems
    return unless current_user

    @available_systems = EmulatorProfile.where(user_selected: true).distinct.pluck(:game_system).compact
  end

  private def load_quick_sync_data
    return unless current_user

    @quick_sync_game = nil
    @quick_sync_save = nil
    @quick_sync_profiles = nil

    game = current_user.current_game
    return unless game

    @quick_sync_game = GameDecorator.new(game)

    latest = @quick_sync_game.game_saves.latest_first.first
    @quick_sync_save = latest ? GameSaveDecorator.new(latest) : nil
    @quick_sync_profiles = EmulatorProfile.selected_for_system(game.system).ordered
  end

  private def require_setup_complete
    return unless current_user
    return if current_user.setup_completed?

    # Allow access to onboarding pages and setup completion
    allowed = [ emulator_profiles_path, games_path, setup_completion_path ]
    return if allowed.any? { |p| request.path.start_with?(p) }

    step_path = next_setup_step_path || games_path
    redirect_to step_path
  end
end
