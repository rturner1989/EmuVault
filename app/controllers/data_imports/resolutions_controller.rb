module DataImports
  class ResolutionsController < MainController
    def create
      @import = DataImport.find(params[:data_import_id])
      @import.update!(resolutions: params.fetch(:resolutions, {}).to_unsafe_h, status: :importing)
      DataImportJob.perform_later(@import.id)
      redirect_to settings_path, notice: "Import started — your library will be restored shortly."
    end
  end
end
