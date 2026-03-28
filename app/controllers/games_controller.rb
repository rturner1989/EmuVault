class GamesController < MainController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    @game = Game.new
    @selected_system = params[:system].presence
    @selected_sort = params[:sort].presence || "title_asc"

    games = Game.all
    games = games.where(system: @selected_system) if @selected_system
    sorted = case @selected_sort
    when "title_desc" then games.order(title: :desc)
    when "newest"     then games.order(created_at: :desc)
    when "oldest"     then games.order(created_at: :asc)
    when "system"     then games.order(:system, :title)
    else                   games.order(:title)
    end

    @pagy, @games = pagy(sorted)

    if params[:append]
      render partial: "games/games_append", locals: { games: @games }, layout: false
      return
    end

    systems_in_use = Game.distinct.pluck(:system).compact
    @system_options = Game::GAME_SYSTEM_OPTIONS.select { |_text, value| systems_in_use.include?(value) }

    scan_result = current_user.last_scan_result || {}
    @pending_scan = scan_result["status"] == "pending_review" && (scan_result["found"] || []).any?
    if @pending_scan
      @scan_found = scan_result["found"] || []
      @scan_already_in_lib = scan_result["already_in_lib"] || 0
      @scan_skipped_paths = scan_result["skipped_paths"] || []
      @scan_grouped = @scan_found.group_by { |item| item["game_system"] }

      current_user.update!(last_scan_result: scan_result.merge("status" => "reviewed"))
    end
  end

  def show
    saves = @game.game_saves.latest_first.includes(:emulator_profile)
    @latest_save = saves.first
    @history = saves.offset(1)
    @new_save = @game.game_saves.build
    @user_profiles = EmulatorProfile.selected_for_system(@game.system).ordered
    @emulator_configs = @game.game_emulator_configs.index_by(&:emulator_profile_id)
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      @pagy, @games = pagy(Game.order(:title))
      @games_count = Game.count
      @games_without_save = Game.left_joins(:game_saves).where(game_saves: { id: nil }).count
      systems_in_use = Game.distinct.pluck(:system).compact
      @system_options = Game::GAME_SYSTEM_OPTIONS.select { |_text, value| systems_in_use.include?(value) }
      @selected_sort = "title_asc"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      @user_profiles = EmulatorProfile.selected_for_system(@game.system).ordered
      @emulator_configs = @game.game_emulator_configs.index_by(&:emulator_profile_id)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    title = @game.title

    if @game.destroy
      current_user.reload
      @notice_text = "#{title} removed."

      if params[:source] == "index"
        @games_count = Game.count
        systems_in_use = Game.distinct.pluck(:system).compact
        @system_options = Game::GAME_SYSTEM_OPTIONS.select { |_text, value| systems_in_use.include?(value) }
      else
        redirect_to games_path, notice: @notice_text, status: :see_other
      end
    else
      @alert_text = "Could not remove #{title}."
    end
  end

  private def set_game
    @game = Game.find(params[:id])
  end

  private def game_params
    params.require(:game).permit(:title, :system, :rom_hash, :cover_image)
  end
end
