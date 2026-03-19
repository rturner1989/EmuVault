class Api::GameSavesController < Api::ApplicationController
  def index
    saves = GameSave.includes(:game, :emulator_profile).order(updated_at: :desc)
    render json: saves.map { |s| serialize_save(s) }
  end

  def show
    save = GameSave.includes(:game, :emulator_profile).find(params[:id])
    render json: serialize_save(save)
  end

  def file
    save = GameSave.includes(:game, :emulator_profile).find(params[:id])
    target_profile = params[:target_profile_id].present? ? EmulatorProfile.find(params[:target_profile_id]) : nil
    decorated = GameSaveDecorator.new(save)

    SyncEvent.create!(
      game_save: save,
      action: :pull,
      status: :success,
      performed_at: Time.current
    )

    send_data save.file.download,
              filename: decorated.download_filename(target_profile),
              disposition: "attachment"
  end

  private def serialize_save(save)
    {
      id: save.id,
      game_id: save.game_id,
      game_title: save.game.title,
      emulator_profile_id: save.emulator_profile_id,
      emulator_name: save.emulator_profile.name,
      platform: save.emulator_profile.platform.value,
      save_extension: save.emulator_profile.save_extension,
      slot: save.slot,
      checksum: save.checksum,
      saved_at: save.saved_at&.iso8601,
      updated_at: save.updated_at.iso8601,
      file_url: Rails.application.routes.url_helpers.file_api_game_save_url(save, host: request.base_url)
    }
  end
end
