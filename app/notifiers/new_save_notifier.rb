# frozen_string_literal: true

class NewSaveNotifier < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      game = event.params[:game_save].game
      profile_name = event.params[:game_save].emulator_profile&.name
      profile_name ? "#{game.title} – new save from #{profile_name}" : "#{game.title} – new save uploaded"
    end

    def game
      event.params[:game_save].game
    end
  end
end
