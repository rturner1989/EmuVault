class DashboardController < ApplicationController
  def index
    @games_count = Game.count
    @devices_count = Device.count
    @emulator_profiles_count = EmulatorProfile.count
    @recent_sync_events = SyncEvent.order(performed_at: :desc).limit(10)
  end
end
