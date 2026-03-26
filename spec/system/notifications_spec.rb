# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Notifications" do
  let(:user) { create(:user, username: "admin", password: "password123", setup_completed: true) }

  before do
    user
    visit new_session_path

    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "notification panel" do
    it "shows empty state when no notifications" do
      visit root_path
      find("[data-action*='notifications#open']").click

      expect(page).to have_text("No notifications yet")
    end

    context "with notifications" do
      let(:game) { create(:game, title: "Zelda", system: :gba) }

      before do
        profile = create(:emulator_profile, game_system: :gba)
        game_save = create(:game_save, game: game, emulator_profile: profile)
        NewSaveNotifier.with(game_save: game_save).deliver(user)
      end

      it "shows unread notifications" do
        visit root_path
        find("[data-action*='notifications#open']").click

        expect(page).to have_text("Zelda")
      end

      it "shows notification badge" do
        visit root_path

        expect(page).to have_css("[data-notification-badge]", text: "1")
      end

      it "marks notification as read and redirects to game" do
        visit root_path
        find("[data-action*='notifications#open']").click
        click_on "Zelda", match: :first

        expect(page).to have_current_path(game_path(game))
      end
    end
  end
end
