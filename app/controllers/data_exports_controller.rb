# frozen_string_literal: true

class DataExportsController < ApplicationController
  def create
    authorize! current_user

    games = Game.includes(:game_emulator_configs, game_saves: [ :emulator_profile, { file_attachment: :blob } ]).all
    zip_data = ExportGenerator.new(games).generate
    filename = "emuvault-export-#{Date.today.iso8601}.zip"
    send_data zip_data, filename: filename, type: "application/zip", disposition: "attachment"
  end
end
