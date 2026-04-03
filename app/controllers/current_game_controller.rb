class CurrentGameController < MainController
  before_action :set_game

  def update
    @previous_game = current_user.current_game
    current_user.update!(current_game: @game)
    @notice = t(".success", title: @game.title)

    respond_to do |format|
      format.turbo_stream { load_quick_sync_data }
      format.html { redirect_back_or_to root_path, notice: @notice }
    end
  end

  def destroy
    current_user.update!(current_game: nil)
    current_user.reload
    @notice = t(".success")

    respond_to do |format|
      format.turbo_stream { load_quick_sync_data }
      format.html { redirect_back_or_to root_path, notice: @notice }
    end
  end

  private def set_game
    @game = Game.find(params[:game_id])
  end
end
