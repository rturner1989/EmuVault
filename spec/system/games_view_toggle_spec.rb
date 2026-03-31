# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Games view toggle" do
  let!(:user) { create(:user, username: "admin", password: "password123", setup_completed: true) }
  let!(:game) { create(:game, title: "Zelda", system: :gba) }

  before do
    create(:game, title: "Mario", system: :gba)
    create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
    create(:emulator_profile, name: "mGBA", platform: :linux, game_system: :gbc, save_extension: "sav", user_selected: true)
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "switching views" do
    it "defaults to card view" do
      visit games_path

      expect(page).to have_css("[data-view-toggle-target='cardView']:not(.hidden)")
      expect(page).to have_css("[data-view-toggle-target='listView'].hidden", visible: :all)
    end

    it "switches to list view" do
      visit games_path

      find("[data-view-toggle-target='listBtn']").click

      expect(page).to have_css("[data-view-toggle-target='listView']:not(.hidden)")
      expect(page).to have_css("[data-view-toggle-target='cardView'].hidden", visible: :all)
    end

    it "persists the view preference across page loads" do
      visit games_path
      find("[data-view-toggle-target='listBtn']").click

      expect(page).to have_css("[data-view-toggle-target='listView']:not(.hidden)")

      visit games_path

      expect(page).to have_css("[data-view-toggle-target='listView']:not(.hidden)")
      expect(page).to have_css("[data-view-toggle-target='cardView'].hidden", visible: :all)
    end
  end

  describe "card view" do
    before { visit games_path }

    it "shows games as cards in a grid" do
      expect(page).to have_text("Zelda")
      expect(page).to have_text("Mario")
      expect(page).to have_css("[data-view-toggle-target='cardView'] .grid")
    end

    it "shows placeholder icon when no cover image" do
      expect(page).to have_css("[data-view-toggle-target='cardView'] .fa-gamepad")
    end

    it "sets a game as current from the card view" do
      within("[data-view-toggle-target='cardView']") do
        first(".group").hover
        first("[title='Set as current game']").click
      end

      expect(page).to have_text("Now playing:")
    end

    it "clears current game from the card view" do
      user.update!(current_game: game)
      visit games_path

      within("[data-view-toggle-target='cardView']") do
        find("[title='Clear current game']").click
      end

      expect(page).to have_text("Cleared current game")
    end

    it "preserves card view after setting current game" do
      within("[data-view-toggle-target='cardView']") do
        first(".group").hover
        first("[title='Set as current game']").click
      end

      expect(page).to have_text("Now playing:")
      expect(page).to have_css("[data-view-toggle-target='cardView']:not(.hidden)")
      expect(page).to have_css("[data-view-toggle-target='listView'].hidden", visible: :all)
    end
  end

  describe "list view" do
    before do
      visit games_path
      find("[data-view-toggle-target='listBtn']").click
    end

    it "shows games in a compact list" do
      within("[data-view-toggle-target='listView']") do
        expect(page).to have_text("Zelda")
        expect(page).to have_text("Mario")
        expect(page).to have_css(".fa-chevron-right", minimum: 2)
      end
    end

    it "sets a game as current from the list view" do
      within("[data-view-toggle-target='listView']") do
        first("[title='Set as current game']").click
      end

      expect(page).to have_text("Now playing:")
    end

    it "preserves list view after setting current game" do
      within("[data-view-toggle-target='listView']") do
        first("[title='Set as current game']").click
      end

      expect(page).to have_text("Now playing:")
      expect(page).to have_css("[data-view-toggle-target='listView']:not(.hidden)")
      expect(page).to have_css("[data-view-toggle-target='cardView'].hidden", visible: :all)
    end
  end

  describe "now playing banner" do
    it "shows the banner when a game is set as current" do
      user.update!(current_game: game)
      visit games_path

      within("#now-playing-banner") do
        expect(page).to have_text("Now Playing")
        expect(page).to have_text("Zelda")
        expect(page).to have_text("Clear")
      end
    end

    it "does not show the banner when no game is current" do
      visit games_path

      within("#now-playing-banner") do
        expect(page).to have_no_text("Now Playing")
      end
    end

    it "clears the current game from the banner" do
      user.update!(current_game: game)
      visit games_path

      within("#now-playing-banner") do
        click_on "Clear"
      end

      expect(page).to have_text("Cleared current game")
      expect(page).to have_no_css("#now-playing-banner .btn")
    end
  end

  describe "infinite scroll" do
    before do
      create_list(:game, 10, system: :gba)
      create(:game, title: "Extra Game", system: :gba)
    end

    it "loads all games across pages in list view" do
      visit games_path
      find("[data-view-toggle-target='listBtn']").click

      within("[data-view-toggle-target='listView']") do
        expect(page).to have_css("[id^='game_']", count: 13, wait: 5)
      end

      expect(page).to have_no_css("[data-load-more-target='sentinel']", visible: :all)
    end

    it "loads all games across pages in card view" do
      visit games_path

      within("[data-load-more-target='cardContainer']") do
        expect(page).to have_css(".group", count: 13, wait: 5)
      end

      expect(page).to have_no_css("[data-load-more-target='sentinel']", visible: :all)
    end

    it "resets pagination when filter changes" do
      create(:game, title: "Tetris GBC", system: :gbc)
      visit games_path

      select "Game Boy Color", from: "system"

      expect(page).to have_text("Tetris GBC")
      expect(page).to have_no_css("[data-load-more-target='sentinel']", visible: :all)
    end
  end
end
