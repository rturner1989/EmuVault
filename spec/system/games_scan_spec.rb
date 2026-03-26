# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Games Scan" do
  before do
    create(:user, username: "admin", password: "password123", setup_completed: true)
    create(:emulator_profile, :default_profile,
      name: "RetroArch", platform: :linux, game_system: :gba,
      save_extension: "srm", user_selected: true)
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "games index empty state" do
    it "shows empty state when no games exist" do
      visit games_path

      expect(page).to have_text("No games yet")
      expect(page).to have_text("Add your first game")
    end

    it "shows games when they exist" do
      create(:game, title: "Zelda", system: :gba)
      visit games_path

      expect(page).to have_text("Zelda")
      expect(page).to have_no_text("No games yet")
    end

    it "shows empty state after removing the last game" do
      game = create(:game, title: "Zelda", system: :gba)
      visit games_path

      expect(page).to have_text("Zelda")

      find("[aria-label='Remove']").click
      within("[id*='remove-game']:not([aria-hidden])") do
        click_on "Remove"
      end

      expect(page).to have_text("Zelda removed")
      expect(page).to have_text("No games yet")
    end
  end

  describe "scan library button" do
    it "shows scanning indicator when clicked" do
      allow(GameScanJob).to receive(:perform_later)
      visit games_path

      click_on "Scan Library"

      expect(page).to have_text("Scanning your library")
    end
  end

  describe "scan review modal" do
    before do
      scan_dir = Dir.mktmpdir
      create(:scan_path, path: scan_dir, game_system: :gba)
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      FileUtils.touch(File.join(scan_dir, "Pokemon.gba"))

      # Run dry_run synchronously to populate last_scan_result
      GameScanJob.perform_now("dry_run")
      visit games_path
    end

    it "has a scan review modal on the page" do
      expect(page).to have_css("[id='scan-review-dialog']", visible: :all)
    end
  end

  describe "game filters update after scan import" do
    it "shows filter bar after games are added" do
      create(:game, title: "Zelda", system: :gba)
      create(:game, title: "Pokemon", system: :gba)
      visit games_path

      expect(page).to have_text("Title A→Z")
      expect(page).to have_text("Zelda")
      expect(page).to have_text("Pokemon")
    end
  end
end
