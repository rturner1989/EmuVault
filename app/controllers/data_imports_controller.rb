# frozen_string_literal: true

require "zip"

class DataImportsController < ApplicationController
  def create
    unless params[:file].present?
      return redirect_to settings_path, alert: "Please select an export file."
    end

    import = DataImport.new(status: :analyzing)
    import.file.attach(params[:file])

    manifest, conflicts = analyze_zip(params[:file])

    if manifest.nil?
      return redirect_to settings_path, alert: "Invalid export file — could not read manifest."
    end

    import.manifest  = manifest
    import.conflicts = conflicts
    import.status    = conflicts.any? ? :conflicts_pending : :pending
    import.save!

    redirect_to review_data_import_path(import)
  end

  def review
    @import = DataImport.find(params[:id])
    manifest = @import.manifest
    conflict_ids = @import.conflicts.map { _1["export_id"] }.to_set

    @new_games       = manifest["games"].reject { conflict_ids.include?(_1["export_id"]) }
    @conflicts       = @import.conflicts
    @profiles        = manifest.fetch("emulator_profiles", [])
    @total_saves     = manifest["games"].sum { _1["saves"].size }
  end

  def resolve
    @import = DataImport.find(params[:id])
    @import.update!(resolutions: params.fetch(:resolutions, {}).to_unsafe_h, status: :importing)
    DataImportJob.perform_later(@import.id)
    redirect_to settings_path, notice: "Import started — your library will be restored shortly."
  end

  private def analyze_zip(uploaded_file)
    Zip::File.open(uploaded_file.tempfile.path) do |zip|
      entry = zip.find_entry("manifest.json")
      return [ nil, [] ] unless entry

      manifest  = JSON.parse(entry.get_input_stream.read)
      conflicts = manifest["games"].select do |g|
        Game.exists?(title: g["title"], system: g["system"])
      end

      [ manifest, conflicts ]
    end
  rescue => e
    Rails.logger.error "[DataImportsController] Failed to analyze zip: #{e.message}"
    [ nil, [] ]
  end
end
