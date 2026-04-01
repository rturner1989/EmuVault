# frozen_string_literal: true

module ScanBroadcasting
  extend ActiveSupport::Concern

  private def broadcast_scan_start(user)
    user.update!(last_scan_result: { "status" => "scanning" })
  end

  private def broadcast_game_added(user, game)
    Turbo::StreamsChannel.broadcast_append_to(
      "scans_#{user.id}",
      target: "onboarding-games-list",
      html: ApplicationController.render(partial: "games/onboarding_game_list_item", locals: { game: game })
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "scans_#{user.id}",
      target: "games-list",
      html: ApplicationController.render(partial: "games/game_list_item", locals: { game: game, current_game_id: user.current_game_id })
    )
  end

  private def broadcast_import_complete(user, result)
    added = result["added"] || 0

    broadcast_clear_scan_progress(user)
    broadcast_flash(user, added)
    broadcast_games_list(user, added)
    broadcast_filters(user)
    broadcast_game_stats(user)
    broadcast_onboarding_banner(user)
  end

  private def broadcast_clear_scan_progress(user)
    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "scan-progress",
      html: ""
    )
  end

  private def broadcast_flash(user, added)
    message = added > 0 ? "#{added} #{"game".pluralize(added)} imported." : "No new games found."

    Turbo::StreamsChannel.broadcast_append_to(
      "scans_#{user.id}",
      target: "flash-container",
      html: ApplicationController.render(Layouts::FlashComponent::Item.new(type: :notice, message: message), layout: false)
    )
  end

  private def broadcast_games_list(user, added)
    return unless added > 0

    games = Game.order(:title)
    partial = user.games_view_preference == "list" ? "games/game_list" : "games/game_card_grid"

    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "games-list",
      html: ApplicationController.render(
        partial: partial,
        locals: { games: games },
        layout: false
      )
    )
  end

  private def broadcast_filters(user)
    games = Game.order(:title)
    system_options = Game.system_options_in_use

    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "games-filters",
      html: ApplicationController.render(
        partial: "games/filters",
        locals: { games_count: games.size, system_options: system_options, selected_system: nil, selected_sort: "title_asc" }
      )
    )
  end

  private def broadcast_game_stats(user)
    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "game_stats",
      html: ApplicationController.render(
        partial: "shared/game_stats",
        locals: {
          games_count: Game.count,
          games_without_save: Game.without_saves.count
        }
      )
    )
  end

  private def broadcast_onboarding_banner(user)
    Turbo::StreamsChannel.broadcast_update_to(
      "scans_#{user.id}",
      target: "onboarding-banner",
      html: ApplicationController.render(
        partial: "shared/onboarding_banner",
        locals: {
          step: 2,
          title: "Add your games",
          description: "Configure scan paths to discover games automatically, or add them manually.",
          back_path: Rails.application.routes.url_helpers.onboarding_emulator_profiles_path,
          next_path: (Rails.application.routes.url_helpers.onboarding_completion_path if Game.exists?),
          next_label: "Complete Setup",
          next_method: (Game.exists? ? :post : nil)
        },
        layout: false
      )
    )
  end
end
