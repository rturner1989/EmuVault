# frozen_string_literal: true

require "zip"

class DataImportsController < ApplicationController
  def create
    authorize! current_user

    unless params[:file].present?
      return redirect_to settings_path, alert: "Please select an export file."
    end

    import = DataImport.new(status: :analyzing)
    import.file.attach(params[:file])

    manifest, conflicts = analyze_zip(params[:file])

    if manifest.nil?
      return redirect_to settings_path, alert: "Invalid export file — could not read manifest."
    end

    import.manifest = manifest
    import.conflicts = conflicts
    import.status = conflicts.any? ? :conflicts_pending : :pending
    import.save!

    redirect_to data_import_review_path(import)
  end

  private def analyze_zip(uploaded_file)
    Zip::File.open(uploaded_file.tempfile.path) do |zip|
      entry = zip.find_entry("manifest.json")
      return [ nil, [] ] unless entry

      manifest = JSON.parse(entry.get_input_stream.read)
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
