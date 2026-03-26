# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings" do
  before do
    create(:user, username: "admin", password: "password123", setup_completed: true)
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "settings page" do
    it "shows the settings sections" do
      visit settings_path

      expect(page).to have_text("Settings")
      expect(page).to have_text("Account")
      expect(page).to have_text("Scan Paths")
      expect(page).to have_text("Theme")
    end
  end

  describe "theme selection" do
    it "shows available themes" do
      visit settings_path

      expect(page).to have_text("Dracula")
      expect(page).to have_text("Night")
    end
  end

  describe "scan settings" do
    it "shows auto-scan schedule options" do
      visit settings_path

      expect(page).to have_text("Auto-scan schedule")
      expect(page).to have_text("Every hour")
    end

    it "adds a scan path" do
      create(:emulator_profile, game_system: :gba, user_selected: true)
      visit settings_path

      find("details", text: "Add scan path").click
      fill_in "Directory path", with: "/test/roms"
      select "Game Boy Advance", from: "scan_path[game_system]"
      click_on "Add path"

      expect(page).to have_text("/test/roms")
    end
  end

  describe "password change" do
    it "shows change password section" do
      visit settings_path

      expect(page).to have_text("Change Password")
    end
  end

  describe "data section" do
    it "shows export and import options" do
      visit settings_path

      expect(page).to have_text("Export library")
      expect(page).to have_text("Import library")
    end
  end

  describe "monitoring section" do
    it "shows monitoring links" do
      visit settings_path

      expect(page).to have_text("PgHero")
      expect(page).to have_text("Sidekiq")
    end
  end
end
