class ActivityController < ApplicationController
  def show
    authorize! SyncEvent, to: :index?
    events = SyncEvent.includes(game_save: :game).recent.limit(100)
    @events = SyncEventDecorator.decorate(events)
  end
end
