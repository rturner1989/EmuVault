class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    authorize! Game
    @games = GameDecorator.decorate(Game.order(:title))
  end

  def show
    authorize! @game
    @game = GameDecorator.new(@game)
    @saves = GameSaveDecorator.decorate(@game.game_saves.includes(:emulator_profile).order(:slot))
    @new_save = @game.game_saves.build
    @sync_events = SyncEvent.joins(:game_save)
                            .where(game_saves: { game_id: @game.id })
                            .includes(game_save: :emulator_profile)
                            .order(performed_at: :desc)
                            .limit(20)
  end

  def new
    authorize! Game, to: :new?
    @form = GameForm.new
  end

  def create
    authorize! Game, to: :create?
    @form = GameForm.new(game_params)
    game = Game.new
    if @form.persist(game)
      redirect_to game, notice: "Game added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! @game
    @form = GameForm.from(@game)
  end

  def update
    authorize! @game
    @form = GameForm.new(game_params)
    @form.id = @game.id
    if @form.persist(@game)
      redirect_to @game, notice: "Game updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @game
    @game.destroy
    redirect_to games_path, notice: "Game removed.", status: :see_other
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:title, :system, :rom_hash)
  end
end
