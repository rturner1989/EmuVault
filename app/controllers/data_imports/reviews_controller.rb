module DataImports
  class ReviewsController < ApplicationController
    def show
      @import = DataImport.find(params[:data_import_id])
      manifest = @import.manifest
      conflict_ids = @import.conflicts.map { |conflict| conflict["export_id"] }.to_set

      @new_games = manifest["games"].reject { |game| conflict_ids.include?(game["export_id"]) }
      @conflicts = @import.conflicts
      @profiles = manifest.fetch("emulator_profiles", [])
      @total_saves = manifest["games"].sum { |game| game["saves"].size }
    end
  end
end
