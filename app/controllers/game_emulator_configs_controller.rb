# frozen_string_literal: true

class GameEmulatorConfigsController < MainController
  before_action :set_game

  def update
    configs_params.each do |emulator_profile_id, save_filename|
      config = @game.game_emulator_configs.find_or_initialize_by(emulator_profile_id: emulator_profile_id)
      if save_filename.blank?
        config.destroy if config.persisted?
      else
        config.save_filename = save_filename.strip
        config.save!
      end
    end
  end

  private def set_game
    @game = Game.find(params[:game_id])
  end

  private def configs_params
    params.permit(emulator_configs: {}).fetch(:emulator_configs, {})
  end
end
