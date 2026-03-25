# Base controller for all post-setup pages that render within the AppShellComponent layout.
# Redirects to the onboarding flow if setup is incomplete and loads layout data
# (quick sync, available systems, onboarding tour flag) for the main app shell.
#
# Controller hierarchy:
#
#   ApplicationController (authentication only)
#     ├── OnboardingController (onboarding layout — login, registration, setup steps)
#     ├── MainController (application layout — all post-setup pages)
#     └── Shared controllers (EmulatorProfilesController, Games::PathsController, etc.)
#         ↳ Turbo frame/stream responders that work in both onboarding and main contexts
#
class MainController < ApplicationController
  before_action :require_setup_complete, unless: -> { current_user.setup_completed? }
  before_action :load_onboarding_flag, if: :html_request?
  before_action :load_quick_sync_data, if: :html_request?
  before_action :load_available_systems, if: :html_request?

  private def html_request?
    request.format.html?
  end

  private def load_onboarding_flag
    @show_onboarding = session.delete(:show_onboarding).present?
  end

  private def load_available_systems
    @available_systems = EmulatorProfile.where(user_selected: true).distinct.pluck(:game_system).compact
  end

  private def load_quick_sync_data
    game = current_user.current_game
    return unless game

    @quick_sync_game = game
    @quick_sync_save = game.game_saves.latest_first.first
    @quick_sync_profiles = EmulatorProfile.selected_for_system(game.system).ordered
  end

  private def require_setup_complete
    if EmulatorProfile.where(user_selected: true).none?
      redirect_to onboarding_emulator_profiles_path
    else
      redirect_to onboarding_games_path
    end
  end
end
