class GameSavesController < ApplicationController
  before_action :set_game
  before_action :set_game_save, only: %i[destroy download]

  def create
    authorize! GameSave, to: :create?

    uploaded = params.dig(:game_save, :file)
    slot = params.dig(:game_save, :slot).to_i
    emulator_profile_id = params.dig(:game_save, :emulator_profile_id)

    existing = @game.game_saves.find_by(emulator_profile_id:, slot:)
    conflict = existing.present?

    @game_save = existing || @game.game_saves.build
    @game_save.assign_attributes(game_save_params)
    @game_save.saved_at = Time.current

    if uploaded.present?
      uploaded.rewind
      @game_save.checksum = Digest::SHA256.hexdigest(uploaded.read)
    end

    if @game_save.save
      SyncEvent.create!(
        game_save: @game_save,
        action: :push,
        status: conflict ? :conflict : :success,
        performed_at: Time.current
      )
      notice = conflict ? "Save replaced (previous version overwritten)." : "Save uploaded."
      redirect_to @game, notice: notice
    else
      @game = GameDecorator.new(@game)
      @saves = GameSaveDecorator.decorate(@game.game_saves.includes(:emulator_profile).order(:slot))
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
    params.require(:game_save).permit(:emulator_profile_id, :slot, :file)
  end
end
