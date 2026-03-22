class LibraryScansController < ApplicationController
  def create
    authorize! current_user

    GameScanJob.perform_now("dry_run")
    redirect_to review_library_scan_path
  end

  def review
    authorize! current_user

    result = current_user.last_scan_result || {}
    @found = result["found"] || []
    @already_in_lib = result["already_in_lib"] || 0
    @skipped_paths = result["skipped_paths"] || []
    @grouped = @found.group_by { |item| item["game_system"] }
  end

  def confirm
    authorize! current_user

    selected_roms = Set.new(params[:selected_roms] || [])
    stored = current_user.last_scan_result&.dig("found") || []
    items = stored.select { |item| selected_roms.include?(item["rom_path"]) }

    if items.any?
      GameScanJob.perform_later("confirm", items)
      redirect_to settings_path, notice: "#{items.size} #{pluralize(items.size, "game")} queued for import — they'll appear in your library shortly."
    else
      redirect_to review_library_scan_path, alert: "No games selected."
    end
  end
end
