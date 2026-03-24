# frozen_string_literal: true

class NewSaveNotifier < Noticed::Event
  notification_methods do
    def message
      game_save = event.params[:game_save]
      return "New save uploaded" unless game_save

      game_title = game_save.game&.title || "Unknown game"
      profile_name = game_save.emulator_profile&.name

      profile_name ? "#{game_title} – new save from #{profile_name}" : "#{game_title} – new save uploaded"
    end

    def game
      event.params[:game_save]&.game
    end
  end
end
