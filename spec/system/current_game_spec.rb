# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Current Game" do
  let!(:user) { create(:user, username: "admin", password: "password123", setup_completed: true) }
  let!(:profile) { create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm") }
  let!(:game) { create(:game, title: "Zelda", system: :gba) }

  before do
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "setting current game from game show page" do
    before { visit game_path(game) }

    it "sets a game as now playing" do
      click_on "Set as current"

      expect(page).to have_text("Now playing: Zelda")
      expect(page).to have_button("Now Playing")
    end

    it "clears now playing" do
      user.update!(current_game: game)
      visit game_path(game)

      click_on "Now Playing"

      expect(page).to have_text("Cleared current game")
      expect(page).to have_button("Set as current")
    end
  end

  describe "setting current game from games index" do
    before { visit games_path }

    it "sets a game as now playing via the rotate icon" do
      find("[title='Set as current game']").click

      expect(page).to have_text("Now playing: Zelda")
    end

    it "clears now playing via the rotate icon" do
      user.update!(current_game: game)
      visit games_path

      find("[title='Clear current game']").click

      expect(page).to have_text("Cleared current game")
      expect(page).to have_no_css("[title='Clear current game']")
    end
  end

  describe "now playing on dashboard" do
    before do
      user.update!(current_game: game)
      visit root_path
    end

    it "shows the now playing section" do
      expect(page).to have_text("Now Playing")
      expect(page).to have_text("Zelda")
    end

    it "clears now playing from the dashboard accordion" do
      find("details", text: "Now Playing").click
      click_on "Clear"

      expect(page).to have_text("Cleared current game")
      expect(page).to have_text("No game set as Now Playing")
    end

    it "navigates to game show via the View link" do
      find("details", text: "Now Playing").click
      click_on "View →"

      expect(page).to have_current_path(game_path(game))
      expect(page).to have_text("Zelda")
    end

    context "with a save file" do
      before do
        create(:game_save, game: game, emulator_profile: profile)
        visit root_path
      end

      it "shows the download section" do
        find("details", text: "Now Playing").click

        expect(page).to have_text("Download to device")
        expect(page).to have_select("game_save[target_profile_id]")
      end

      it "shows the upload section" do
        find("details", text: "Now Playing").click

        expect(page).to have_text("Upload new save")
        expect(page).to have_text("Choose file")
      end
    end

    context "without a save file" do
      it "shows no save message" do
        find("details", text: "Now Playing").click

        expect(page).to have_text("No save uploaded yet")
      end

      it "shows the upload section" do
        find("details", text: "Now Playing").click

        expect(page).to have_text("Upload new save")
      end
    end
  end
end
