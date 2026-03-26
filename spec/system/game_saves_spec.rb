# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Game Saves" do
  let(:profile) { create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm", default_save_path: "~/.config/retroarch/saves") }
  let(:game) { create(:game, title: "Zelda", system: :gba) }

  before do
    profile
    game
    create(:user, username: "admin", password: "password123", setup_completed: true)
    visit new_session_path

    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "uploading a save file" do
    it "uploads a save file with emulator profile" do
      visit game_path(game)

      select "RetroArch (Linux) (.srm)", from: "game_save[emulator_profile_id]"
      attach_file "game_save[file]", file_fixture("test_save.srm"), make_visible: true
      find("[type='submit']", text: "Upload Save").click

      expect(page).to have_text("Save uploaded")
      expect(page).to have_text("RetroArch")
      expect(page).to have_text("Current Save")
    end

    it "uploads a save file without selecting an emulator" do
      visit game_path(game)

      attach_file "game_save[file]", file_fixture("test_save.srm"), make_visible: true
      find("[type='submit']", text: "Upload Save").click

      expect(page).to have_text("Save uploaded")
      expect(page).to have_text("Unknown source")
    end

    it "shows error when no file is selected" do
      visit game_path(game)

      find("[type='submit']", text: "Upload Save").click

      expect(page).to have_text("can't be blank")
    end

    it "shows upload new version when a save already exists" do
      create(:game_save, game: game, emulator_profile: profile)
      visit game_path(game)

      expect(page).to have_text("Upload New Version")
    end
  end

  describe "downloading a save file" do
    before do
      create(:game_save, game: game, emulator_profile: profile)
    end

    it "shows the download button" do
      visit game_path(game)

      expect(page).to have_text("Download")
    end

    it "shows save path hint when profile is selected" do
      visit game_path(game)

      select "RetroArch (Linux) (.srm)", from: "game_save[target_profile_id]"

      expect(page).to have_text("Place the downloaded file at")
    end
  end

  describe "save history" do
    it "shows previous versions" do
      create_list(:game_save, 2, game: game, emulator_profile: profile)
      visit game_path(game)

      expect(page).to have_text("Previous Versions")
    end

    it "shows view all link when more than 5 saves" do
      create_list(:game_save, 7, game: game, emulator_profile: profile)
      visit game_path(game)

      expect(page).to have_text("View all 6")
    end
  end
end
