# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Navigation" do
  before do
    create(:user, username: "admin", password: "password123", setup_completed: true)
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard") # wait for redirect without using expect in hook
  end

  describe "sidebar links" do
    it "navigates to Games" do
      find_by_id('nav-games').click

      expect(page).to have_current_path(games_path)
      expect(page).to have_text("Games")
    end

    it "navigates to Activity" do
      find_by_id('nav-activity').click

      expect(page).to have_current_path(activity_path)
      expect(page).to have_text("Activity")
    end

    it "navigates to Emulator Profiles" do
      find_by_id('nav-profiles').click

      expect(page).to have_current_path(emulator_profiles_path)
      expect(page).to have_text("Emulator Profiles")
    end

    it "navigates to Settings" do
      find_by_id('nav-settings').click

      expect(page).to have_current_path(settings_path)
      expect(page).to have_text("Settings")
    end

    it "navigates back to Dashboard" do
      find_by_id('nav-games').click
      expect(page).to have_current_path(games_path)

      click_on "Dashboard"

      expect(page).to have_current_path(root_path)
      expect(page).to have_text("Dashboard")
    end
  end

  describe "user section" do
    it "displays the username" do
      expect(page).to have_text("admin")
    end

    it "signs out" do
      click_on "Sign Out"

      expect(page).to have_current_path(new_session_path)
      expect(page).to have_text("Sign in to your vault")
    end
  end

  describe "notification panel" do
    it "opens the notification panel" do
      find_by_id('nav-notifications').click

      expect(page).to have_text("Notifications")
      expect(page).to have_text("Mark all as read")
    end

    it "closes the notification panel with close button" do
      find_by_id('nav-notifications').click
      expect(page).to have_text("Mark all as read")

      within "[data-notifications-target='panel']" do
        find("[data-action='click->notifications#close']").click
      end

      expect(page).to have_no_css("[data-notifications-target='panel'].translate-x-0")
    end
  end

  describe "cross-page navigation" do
    it "navigates between main pages sequentially" do
      # Dashboard → Games
      find_by_id('nav-games').click
      expect(page).to have_text("Games")
      expect(page).to have_current_path(games_path)

      # Games → Activity
      find_by_id('nav-activity').click
      expect(page).to have_text("Activity")
      expect(page).to have_current_path(activity_path)

      # Activity → Emulator Profiles
      find_by_id('nav-profiles').click
      expect(page).to have_text("Emulator Profiles")
      expect(page).to have_current_path(emulator_profiles_path)

      # Emulator Profiles → Settings
      find_by_id('nav-settings').click
      expect(page).to have_text("Settings")
      expect(page).to have_current_path(settings_path)

      # Settings → Dashboard
      click_on "Dashboard"
      expect(page).to have_text("Dashboard")
      expect(page).to have_current_path(root_path)
    end
  end

  describe "admin tools" do
    it "can access Sidekiq dashboard" do
      visit "/sidekiq"

      expect(page).to have_text("Sidekiq")
    end

    it "can access PgHero dashboard" do
      visit "/pghero"

      expect(page).to have_text("PgHero")
    end
  end
end
