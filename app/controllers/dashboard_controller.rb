class DashboardController < ApplicationController
  def index
    @games_count = Game.count
    @sync_events_count = SyncEvent.count
    @emulator_profiles_count = EmulatorProfile.where(user_selected: true).count
    @recent_sync_events = SyncEventDecorator.decorate(SyncEvent.includes(game_save: :game).recent.limit(10))
  end
end
