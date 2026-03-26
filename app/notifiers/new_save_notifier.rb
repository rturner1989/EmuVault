# frozen_string_literal: true

class NewSaveNotifier < ApplicationNotifier
  notification_methods do
    def game_save
      event.params[:game_save]
    end

    def game
      game_save&.game
    end

    def message
      return "New save uploaded" unless game_save

      game_title = game.title || "Unknown game"
      profile_name = game_save.emulator_profile&.name

      profile_name ? "#{game_title} – new save from #{profile_name}" : "#{game_title} – new save uploaded"
    end
  end
end
