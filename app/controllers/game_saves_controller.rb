class GameSavesController < ApplicationController
  before_action :set_game
  before_action :set_game_save, only: %i[destroy download]

  def create
    authorize! GameSave, to: :create?

    uploaded = params.dig(:game_save, :file)
    emulator_profile_id = params.dig(:game_save, :emulator_profile_id).presence

    @game_save = @game.game_saves.build(game_save_params)
    @game_save.saved_at = Time.current

    if uploaded.present?
      uploaded.rewind
      @game_save.checksum = Digest::SHA256.hexdigest(uploaded.read)
    end

    if @game_save.save
      SyncEvent.create!(
        game_save: @game_save,
        action: :push,
        status: :success,
        performed_at: Time.current
      )
      redirect_to @game, notice: "Save uploaded."
    else
      @game = GameDecorator.new(@game)
      @latest_save = GameSaveDecorator.decorate(@game.game_saves.latest_first.first) if @game.game_saves.exists?
      @history = @game.game_saves.latest_first.offset(1).includes(:emulator_profile).limit(19)
      @new_save = @game_save
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

    target_profile = params[:target_profile_id].present? ? EmulatorProfile.find(params[:target_profile_id]) : nil
    decorated = GameSaveDecorator.new(@game_save)

    SyncEvent.create!(
      game_save: @game_save,
      action: :pull,
      status: :success,
      performed_at: Time.current
    )

    send_data @game_save.file.download,
              filename: decorated.download_filename(target_profile),
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
