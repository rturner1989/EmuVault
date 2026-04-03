# frozen_string_literal: true

class DataImportsController < MainController
  def create
    unless params[:file].present?
      return redirect_to settings_path, alert: t(".no_file")
    end

    import = DataImport.new(status: :analyzing)
    import.file.attach(params[:file])

    manifest, conflicts = DataImport.analyze_zip(params[:file])

    if manifest.nil?
      return redirect_to settings_path, alert: t(".invalid")
    end

    import.manifest = manifest
    import.conflicts = conflicts
    import.status = conflicts.any? ? :conflicts_pending : :pending
    import.save!

    redirect_to data_import_review_path(import)
  end
end
