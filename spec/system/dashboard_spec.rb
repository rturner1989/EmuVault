# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard" do
  let!(:user) { create(:user, username: "admin", password: "password123", setup_completed: true) }

  before do
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard") # wait for redirect without using expect in hook
  end

  def open_add_game_dialog
    find_by_id('add-game-btn').click
    expect(page).to have_css("[id='add-game-dialog']:not([aria-hidden])")
  end

  def dialog_closed?
    page.has_css?("[id='add-game-dialog'][aria-hidden='true']", visible: :all)
  end

  def fill_game_form(title:, system: "Game Boy Advance")
    fill_in "Title", with: title
    find("[id='add-game-dialog'] select").select(system)
  end

  def submit_game_form
    find("[form='add-game-form'][type='submit']").click
  end

  describe "stat cards" do
    it "shows all four stat cards" do
      expect(page).to have_text("Games")
      expect(page).to have_text("Needs Upload")
      expect(page).to have_text("Storage Used")
      expect(page).to have_text("Sync Events")
    end

    it "shows zero counts initially" do
      within "[id='game_stats']" do
        expect(page).to have_text("0")
      end
    end

    context "with games" do
      before do
        create(:game, title: "Pokemon Emerald", system: :gba)
        visit root_path
      end

      it "shows the games count" do
        expect(page).to have_text("1")
      end

      it "shows needs upload count" do
        within "[id='game_stats']" do
          expect(page).to have_text("Needs Upload")
        end
      end
    end
  end

  describe "stat card links" do
    it "navigates to games page from Games card" do
      click_on "View all", match: :first

      expect(page).to have_current_path(games_path)
    end
  end

  describe "empty states" do
    it "shows no activity message" do
      expect(page).to have_text("No activity yet.")
    end

    it "shows no syncs message" do
      expect(page).to have_text("No syncs yet.")
    end

    it "shows no games message in systems section" do
      expect(page).to have_text("No games yet.")
    end

    it "shows now playing empty state" do
      expect(page).to have_text("No game set as Now Playing")
    end
  end

  describe "add game modal" do
    it "opens the add game dialog" do
      open_add_game_dialog

      expect(page).to have_field("Title")
    end

    it "closes the dialog with Cancel" do
      open_add_game_dialog
      click_on "Cancel"

      expect(dialog_closed?).to be true
    end

    it "closes the dialog with the X button" do
      open_add_game_dialog

      find("[id='add-game-dialog'] [aria-label='Close']").click

      expect(dialog_closed?).to be true
    end

    it "shows validation errors when title is blank" do
      open_add_game_dialog
      find("[id='add-game-dialog'] select").select("Game Boy Advance")
      submit_game_form

      expect(page).to have_text("can't be blank")
    end

    it "shows validation errors when system is blank" do
      open_add_game_dialog
      fill_in "Title", with: "Pokemon Emerald"
      submit_game_form

      expect(page).to have_text("can't be blank")
    end

    it "shows validation errors when both fields are blank" do
      open_add_game_dialog
      submit_game_form

      expect(page).to have_text("can't be blank")
    end

    context "with emulator profiles" do
      before do
        create(:emulator_profile, :default_profile,
          name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
      end

      it "creates a game successfully" do
        open_add_game_dialog
        fill_game_form(title: "Pokemon Emerald")
        submit_game_form

        expect(page).to have_text("Pokemon Emerald added")
        expect(Game.count).to eq(1)
      end

      it "updates stat cards after creating a game" do
        open_add_game_dialog
        fill_game_form(title: "Pokemon Emerald")
        submit_game_form

        expect(page).to have_text("Pokemon Emerald added")

        within "[id='game_stats']" do
          expect(page).to have_text("1")
        end
      end

      it "closes the dialog after successful creation" do
        open_add_game_dialog
        fill_game_form(title: "Pokemon Emerald")
        submit_game_form

        expect(page).to have_text("Pokemon Emerald added")
        expect(dialog_closed?).to be true
      end

      it "can add multiple games" do
        # First game
        open_add_game_dialog
        fill_game_form(title: "Pokemon Emerald")
        submit_game_form
        expect(page).to have_text("Pokemon Emerald added")

        # Second game
        open_add_game_dialog
        fill_game_form(title: "Zelda")
        submit_game_form
        expect(page).to have_text("Zelda added")

        expect(Game.count).to eq(2)
      end
    end
  end

  describe "now playing" do
    let!(:game) { create(:game, title: "Zelda", system: :gba) }

    it "shows empty state when no game is set" do
      expect(page).to have_text("No game set as Now Playing")
    end

    context "with current game set" do
      before do
        user.update!(current_game: game)
        visit root_path
      end

      it "shows the now playing section" do
        expect(page).to have_text("Zelda")
        expect(page).to have_text("No save uploaded yet")
      end
    end
  end

  describe "recent activity" do
    context "with sync events" do
      before do
        game = create(:game, title: "Pokemon Emerald", system: :gba)
        game_save = create(:game_save, game: game)
        create(:sync_event, game_save: game_save, action: :push, status: :success)
        visit root_path
      end

      it "shows recent sync events" do
        expect(page).to have_text("Recent Activity")
        expect(page).to have_text("Pokemon Emerald")
      end

      it "links to the activity page" do
        within ".rounded-lg", text: "Recent Activity" do
          click_on "View all"
        end

        expect(page).to have_current_path(activity_path)
      end
    end
  end

  describe "systems section" do
    before do
      create(:game, title: "Pokemon Emerald", system: :gba)
      visit root_path
    end

    it "shows system counts" do
      expect(page).to have_text("Systems")
      expect(page).to have_text("GBA")
      expect(page).to have_text("1 game")
    end
  end

  describe "top games" do
    context "with sync events" do
      before do
        game = create(:game, title: "Pokemon Emerald", system: :gba)
        game_save = create(:game_save, game: game)
        create(:sync_event, game_save: game_save, action: :push, status: :success)
        visit root_path
      end

      it "shows most active games" do
        expect(page).to have_text("Most Active Games")
        expect(page).to have_text("Pokemon Emerald")
        expect(page).to have_text("1 sync")
      end
    end
  end
end
