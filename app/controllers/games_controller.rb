class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    authorize! Game
    @form = GameForm.new
    @selected_system = params[:system].presence
    games = Game.order(:title)
    games = games.where(system: @selected_system) if @selected_system
    @games = GameDecorator.decorate(games)
  end

  def show
    authorize! @game
    @game = GameDecorator.new(@game)
    saves = @game.game_saves.latest_first.includes(:emulator_profile)
    @latest_save = GameSaveDecorator.decorate(saves.first) if saves.exists?
    @history = saves.offset(1).limit(19)
    @new_save = @game.game_saves.build
    @user_profiles = EmulatorProfile.where(user_selected: true).ordered
    @form = GameForm.from(@game)
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
