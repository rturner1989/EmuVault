module GameSaves
  class DownloadsController < ApplicationController
    before_action :set_game
    before_action :set_game_save

    def show
      target_profile_id = params.dig(:game_save, :target_profile_id)
      target_profile = target_profile_id.present? ? EmulatorProfile.find(target_profile_id) : nil
      SyncEvent.create!(
        game_save: @game_save,
        action: :pull,
        status: :success,
        performed_at: Time.current,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )

      filename = @game_save.download_filename(target_profile)
      response.headers["Content-Type"] = "application/octet-stream"
      response.headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      render body: @game_save.file.download
    end

    private def set_game
      @game = Game.find(params[:game_id])
    end

    private def set_game_save
      @game_save = @game.game_saves.find(params[:game_save_id])
    end
  end
end
