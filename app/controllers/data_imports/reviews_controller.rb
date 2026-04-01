module DataImports
  class ReviewsController < MainController
    def show
      @import = DataImport.find(params[:data_import_id])
    end
  end
end
