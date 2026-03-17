class ApplicationController < ActionController::Base
  include Authentication
  include ActionPolicy::Behaviour

  allow_browser versions: :modern

  helper_method :current_user

  before_action :require_setup_complete
  before_action :load_onboarding_flag
  before_action :load_quick_sync_data

  private

  def current_user
    Current.user
  end

  def load_onboarding_flag
    @show_onboarding = session.delete(:show_onboarding).present?
  end

  def load_quick_sync_data
    return unless current_user
    game = current_user.current_game
    return unless game

    @quick_sync_game = GameDecorator.new(game)

    latest = @quick_sync_game.game_saves.latest_first.first
    @quick_sync_save = latest ? GameSaveDecorator.new(latest) : nil
    @quick_sync_profiles = EmulatorProfile.where(user_selected: true).ordered
  end

  def require_setup_complete
    return unless current_user
    return if current_user.setup_completed?
    return if controller_name == "setup" || controller_name == "sessions" || controller_name == "passwords" || controller_name == "directory_browser" || controller_name == "scan_paths"

    redirect_to setup_path
  end
end
