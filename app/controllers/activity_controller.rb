class ActivityController < ApplicationController
  def show
    authorize! SyncEvent, to: :index?
    @games = Game.order(:title)
    @selected_game_id = params[:game_id].presence
    events = SyncEvent.includes(game_save: :game).recent
    events = events.joins(game_save: :game).where(games: { id: @selected_game_id }) if @selected_game_id
    @events = SyncEventDecorator.decorate(events.limit(100))
  end
end
