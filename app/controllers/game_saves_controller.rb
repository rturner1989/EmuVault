class GameSavesController < ApplicationController
  before_action :set_game
  before_action :set_game_save, only: %i[destroy download]

  def create
    authorize! GameSave, to: :create?

    @game_save_form = GameSaveForm.new(game_save_params)

    if @game_save_form.save(game: @game, request: request)
      redirect_back_or_to game_path(@game), notice: "Save uploaded."
    else
      @game = GameDecorator.new(@game)
      @latest_save = GameSaveDecorator.decorate(@game.game_saves.latest_first.first) if @game.game_saves.exists?
      @history = @game.game_saves.latest_first.offset(1).includes(:emulator_profile).limit(19)
      @new_save = @game_save_form
      @user_profiles = EmulatorProfile.where(user_selected: true).ordered
      @emulator_configs = @game.game_emulator_configs.index_by(&:emulator_profile_id)
      @form = GameForm.from(@game)
      render "games/show", status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @game_save
    @game_save.destroy
    redirect_to @game, notice: "Save removed.", status: :see_other
  end

  def download
    authorize! @game_save, to: :show?

    target_profile_id = params.dig(:game_save, :target_profile_id)
    target_profile = target_profile_id.present? ? EmulatorProfile.find(target_profile_id) : nil
    decorated = GameSaveDecorator.new(@game_save)

    SyncEvent.create!(
      game_save: @game_save,
      action: :pull,
      status: :success,
      performed_at: Time.current,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    send_data @game_save.file.download,
              filename: decorated.download_filename(target_profile),
              type: "application/octet-stream",
              disposition: "attachment"
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_game_save
    @game_save = @game.game_saves.find(params[:id])
  end

  def game_save_params
    params.require(:game_save).permit(:emulator_profile_id, :file)
  end
end
