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
    when "newest" then games.order(created_at: :desc)
    when "oldest" then games.order(created_at: :asc)
    when "system" then games.order(:system, :title)
    else games.order(:title)
    end

    # System sort groups games by system with headers — pagination appends
    # flat items which breaks the grouping, so load all games for this sort.
    if @selected_sort == "system"
      @games = sorted.to_a
      @pagy = nil
    else
      @pagy, @games = pagy(sorted)
    end

    if params[:paginate]
      render partial: "games/games_page", locals: { games: @games, pagy: @pagy, selected_sort: @selected_sort, selected_system: @selected_system }, layout: false
      return
    end

    @system_options = Game.system_options_in_use

    load_pending_scan
  end

  def show
    saves = @game.game_saves.latest_first.includes(:emulator_profile).to_a
    total = saves.size
    saves.each_with_index { |save, i| save.version_number = total - i }

    @latest_save = saves.first
    @history = saves.drop(1)
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
      @games_without_save = Game.without_saves.count
      @system_options = Game.system_options_in_use
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
      @notice_text = t(".success", title: title)

      if params[:source] == "index"
        @games_count = Game.count
        @system_options = Game.system_options_in_use
      else
        redirect_to games_path, notice: @notice_text, status: :see_other
      end
    else
      @alert_text = t(".failure", title: title)
    end
  end

  private def set_game
    @game = Game.find(params[:id])
  end

  private def game_params
    params.require(:game).permit(:title, :system, :rom_hash, :cover_image)
  end

  private def load_pending_scan
    scan_result = current_user.last_scan_result || {}
    @pending_scan = scan_result["status"] == "pending_review" && (scan_result["found"] || []).any?

    return unless @pending_scan

    @scan_found = scan_result["found"] || []
    @scan_already_in_lib = scan_result["already_in_lib"] || 0
    @scan_skipped_paths = scan_result["skipped_paths"] || []
    @scan_grouped = @scan_found.group_by { |item| item["game_system"] }
  end
end
