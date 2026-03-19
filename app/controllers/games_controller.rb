class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    authorize! Game

    @form = GameForm.new
    @selected_system = params[:system].presence
    @selected_sort = params[:sort].presence || "title_asc"

    games = Game.all
    games = games.where(system: @selected_system) if @selected_system
    games = case @selected_sort
    when "title_desc" then games.order(title: :desc)
    when "newest"     then games.order(created_at: :desc)
    when "oldest"     then games.order(created_at: :asc)
    when "system"     then games.order(:system, :title)
    else                   games.order(:title)
    end

    @games = GameDecorator.decorate(games)
    @system_options = Game.system.options.select { |_text, value| Game.distinct.pluck(:system).compact.include?(value) }
  end

  def show
    authorize! @game

    @game = GameDecorator.new(@game)
    saves = @game.game_saves.latest_first.includes(:emulator_profile)
    @latest_save = GameSaveDecorator.decorate(saves.first) if saves.exists?
    @history = saves.offset(1)
    @new_save = @game.game_saves.build
    @user_profiles = EmulatorProfile.selected_for_system(@game.system).ordered
    @emulator_configs = @game.game_emulator_configs.index_by(&:emulator_profile_id)
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
      render turbo_stream: turbo_stream.replace(:game_form,
        partial: "games/form",
        locals: { form_url: games_path, form_id: "add-game-form" }), status: :unprocessable_entity
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
      @form = GameForm.from(@game)
      render turbo_stream: [
        turbo_stream.replace("game_header", partial: "games/header", locals: { game: GameDecorator.new(@game) }),
        turbo_stream.append("flash-container",
          ::Layouts::FlashComponent::Item.new(type: :notice, message: "#{@game.title} updated."))
      ]
    else
      render turbo_stream: turbo_stream.replace(:game_form,
        partial: "games/form",
        locals: { form_url: game_path(@game), form_id: "edit-game-form" }), status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @game

    title = @game.title
    was_current = current_user.current_game_id == @game.id

    if @game.destroy
      current_user.update!(current_game: nil) if was_current
      notice_text = "#{title} removed."

      if params[:source] == "index"
        load_quick_sync_data if was_current
        games = GameDecorator.decorate(Game.order(:title))
        streams = [
          turbo_stream.update("games-list", partial: "games/game_list", locals: { games: games }),
          turbo_stream.append("flash-container",
            ::Layouts::FlashComponent::Item.new(type: :notice, message: notice_text))
        ]
        streams << turbo_stream.update(:quick_sync_content, partial: "shared/quick_sync_content") if was_current
        render turbo_stream: streams
      else
        redirect_to games_path, notice: notice_text, status: :see_other
      end
    else
      redirect_back_or_to game_path(@game), alert: "Could not remove #{title}."
    end
  end

  private def set_game
    @game = Game.find(params[:id])
  end

  private def game_params
    params.require(:game).permit(:title, :system, :rom_hash)
  end
end
