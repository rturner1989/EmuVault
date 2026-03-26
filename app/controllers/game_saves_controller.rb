class GameSavesController < MainController
  before_action :set_game
  before_action :set_game_save, only: [ :destroy ]

  def create
    @game_save_form = GameSaveForm.new(game_save_params)
    if @game_save_form.save(game: @game, request: request)
      redirect_back_or_to game_path(@game), notice: "Save uploaded."
    else
      @latest_save = @game.game_saves.latest_first.first
      @history = @game.game_saves.latest_first.offset(1).includes(:emulator_profile).limit(19)
      @new_save = @game_save_form
      @user_profiles = EmulatorProfile.where(user_selected: true).ordered
      @emulator_configs = @game.game_emulator_configs.index_by(&:emulator_profile_id)

      render "games/show", status: :unprocessable_entity
    end
  end

  def destroy
    if @game_save.destroy
      redirect_to @game, notice: "Save removed.", status: :see_other
    else
      redirect_back_or_to game_path(@game), alert: "Could not remove save."
    end
  end

  private def set_game
    @game = Game.find(params[:game_id])
  end

  private def set_game_save
    @game_save = @game.game_saves.find(params[:id])
  end

  private def game_save_params
    params.require(:game_save).permit(:emulator_profile_id, :file)
  end
end
