# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Activity" do
  before do
    create(:user, username: "admin", password: "password123", setup_completed: true)
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "activity page" do
    it "shows the activity page" do
      visit activity_path

      expect(page).to have_text("Activity")
    end

    it "shows empty state when no sync events" do
      visit activity_path

      expect(page).to have_text("No activity yet")
    end

    context "with sync events" do
      before do
        game = create(:game, title: "Zelda", system: :gba)
        game_save = create(:game_save, game: game)
        create(:sync_event, game_save: game_save, action: :push, status: :success)
        create(:sync_event, game_save: game_save, action: :pull, status: :success)
      end

      it "shows sync events" do
        visit activity_path

        expect(page).to have_text("Zelda")
        expect(page).to have_text("2 events")
        expect(page).to have_text("Desktop")
      end

      it "filters by game" do
        other_game = create(:game, title: "Pokemon", system: :gba)
        other_save = create(:game_save, game: other_game)
        create(:sync_event, game_save: other_save, action: :push, status: :success)

        visit activity_path
        select "Zelda", from: "game_id"

        expect(page).to have_text("Zelda")
      end

      it "sorts by oldest first" do
        visit activity_path
        select "Oldest first", from: "sort"

        expect(page).to have_text("Zelda")
      end
    end
  end
end
