# frozen_string_literal: true

module Games
  class ViewPreferencesController < MainController
    def update
      view = params[:view]
      current_user.update!(games_view_preference: view) if User::GAMES_VIEW_PREFERENCES.include?(view)

      redirect_to games_path(sort: params[:sort], system: params[:system]), status: :see_other
    end
  end
end
