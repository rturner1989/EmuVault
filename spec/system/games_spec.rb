# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Games" do
  let!(:profile) { create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm") }
  let!(:game) { create(:game, title: "Zelda", system: :gba) }

  before do
    create(:user, username: "admin", password: "password123", setup_completed: true)
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "games index" do
    it "shows games in the list" do
      visit games_path

      expect(page).to have_text("Zelda")
      expect(page).to have_text("Game Boy Advance")
    end

    it "filters by system" do
      create(:game, title: "Mario", system: :snes)
      create(:emulator_profile, game_system: :snes, user_selected: true)
      visit games_path

      select "SNES", from: "system"

      expect(page).to have_text("Mario")
    end
  end

  describe "game show page" do
    it "shows game details" do
      visit game_path(game)

      expect(page).to have_text("Zelda")
      expect(page).to have_text("Game Boy Advance")
    end

    it "shows upload form when no saves exist" do
      visit game_path(game)

      expect(page).to have_text("Upload")
    end

    context "with a save file" do
      before do
        create(:game_save, game: game, emulator_profile: profile)
        visit game_path(game)
      end

      it "shows the current save" do
        expect(page).to have_text("RetroArch")
      end

      it "shows download button" do
        expect(page).to have_text("Download")
      end
    end

    it "edits a game" do
      visit game_path(game)
      click_on "Edit"

      fill_in "Title", with: "Zelda Updated"
      find("[form*='edit-game'][type='submit']").click

      expect(page).to have_text("Zelda Updated")
    end

    it "removes a game" do
      visit game_path(game)
      click_on "Remove"

      within("[id='remove-game-dialog']:not([aria-hidden])") do
        click_on "Remove"
      end

      expect(page).to have_current_path(games_path)
      expect(page).to have_text("Zelda removed")
    end
  end

  describe "add game from index" do
    it "adds a game via the modal" do
      visit games_path

      click_on "Add Game"
      fill_in "Title", with: "Pokemon"
      find("[id='add-game-dialog'] select").select("Game Boy Advance")
      find("[form='add-game-form'][type='submit']").click

      expect(page).to have_text("Pokemon added")
      expect(page).to have_text("Pokemon")
    end

    it "shows validation errors" do
      visit games_path

      click_on "Add Game"
      find("[form='add-game-form'][type='submit']").click

      expect(page).to have_text("can't be blank")
    end
  end
end
