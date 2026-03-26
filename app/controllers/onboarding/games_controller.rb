module Onboarding
  class GamesController < StepController
    before_action :load_available_systems
    before_action :set_game, only: [ :destroy ]

    def index
      @game = Game.new
      @games = Game.order(:title)
      @scan_paths = ScanPath.ordered
    end

    def create
      @game = Game.new(game_params)
      if @game.save
        @games = Game.order(:title)
      else
        @games = Game.order(:title)
        @scan_paths = ScanPath.ordered
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      if @game.destroy
        @notice_text = "#{@game.title} removed."
      else
        @alert_text = "Could not remove #{@game.title}."
      end
    end

    private def set_game
      @game = Game.find(params[:id])
    end

    private def game_params
      params.require(:game).permit(:title, :system, :rom_hash)
    end

    private def load_available_systems
      @available_systems = EmulatorProfile.where(user_selected: true)
        .distinct
        .pluck(:game_system)
        .compact
    end
  end
end
