# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Setup wizard" do
  let!(:user) { create(:user, username: "admin", password: "password123", setup_completed: false) }

  before do
    # Seed default profiles — these would normally come from db:seed
    create(:emulator_profile, :default_profile, :unselected,
      name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
    create(:emulator_profile, :default_profile, :unselected,
      name: "Delta", platform: :ios, game_system: :gba, save_extension: "sav")
    create(:emulator_profile, :default_profile, :unselected,
      name: "RetroArch", platform: :linux, game_system: :snes, save_extension: "srm")
  end

  def sign_in
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    expect(page).to have_no_text("Sign in to your vault")
  end

  def select_label(text)
    find("label", text: text).click
  end

  describe "step 1 — system selection" do
    before { sign_in }

    it "redirects to the setup wizard after login" do
      expect(page).to have_current_path(profiles_setup_path)
      expect(page).to have_text("Which systems do you use?")
    end

    it "shows available game systems" do
      expect(page).to have_text("Game Boy Advance")
      expect(page).to have_text("SNES")
    end

    it "requires at least one system to be selected" do
      click_button "Next"

      expect(page).to have_text("Please select at least one system")
    end

    it "advances to emulator selection after choosing a system" do
      select_label "Game Boy Advance"
      click_button "Next"

      expect(page).to have_text("Game Boy Advance")
      expect(page).to have_text("Select the emulators you have installed")
    end
  end

  describe "step 1b — emulator selection" do
    before do
      sign_in
      select_label "Game Boy Advance"
      click_button "Next"
    end

    it "shows available emulators for the selected system" do
      expect(page).to have_text("RetroArch")
      expect(page).to have_text("Delta")
    end

    it "advances to step 2 after selecting emulators" do
      select_label "RetroArch"
      click_button "Continue"

      expect(page).to have_text("Where do your emulators store saves?")
    end

    it "can go back to system selection" do
      click_on "Back"

      expect(page).to have_text("Which systems do you use?")
    end
  end

  describe "step 2 — save paths" do
    before do
      EmulatorProfile.where(name: "RetroArch", game_system: :gba).update_all(user_selected: true)
      sign_in
      visit configure_setup_path
    end

    it "shows emulator path configuration" do
      expect(page).to have_text("Where do your emulators store saves?")
      expect(page).to have_text("RetroArch")
    end

    it "advances to step 3" do
      click_button "Next"

      expect(page).to have_text("Set up your games library")
    end

    it "can go back to step 1" do
      click_on "Back"

      expect(page).to have_text("Which systems do you use?")
    end
  end

  describe "step 3 — library setup" do
    before do
      EmulatorProfile.where(name: "RetroArch", game_system: :gba).update_all(user_selected: true)
      sign_in
      visit library_setup_path
    end

    it "shows library configuration" do
      expect(page).to have_text("Set up your games library")
    end

    it "completes setup and redirects to the app" do
      click_button "Finish setup"

      expect(page).to have_current_path(root_path)
      expect(user.reload.setup_completed).to be true
    end

    it "can go back to step 2" do
      click_on "Back"

      expect(page).to have_text("Where do your emulators store saves?")
    end
  end

  describe "full wizard flow" do
    before { sign_in }

    it "completes all steps end to end" do
      # Step 1a — select systems
      expect(page).to have_text("Which systems do you use?")
      select_label "Game Boy Advance"
      click_button "Next"

      # Step 1b — select emulators
      expect(page).to have_text("Select the emulators you have installed")
      select_label "RetroArch"
      click_button "Continue"

      # Step 2 — save paths (skip, leave blank)
      expect(page).to have_text("Where do your emulators store saves?")
      click_button "Next"

      # Step 3 — library setup (finish)
      expect(page).to have_text("Set up your games library")
      click_button "Finish setup"

      # Redirected to app
      expect(page).to have_current_path(root_path)
      expect(user.reload.setup_completed).to be true
    end
  end

  describe "setup guard" do
    it "prevents access to the main app during setup" do
      sign_in
      visit games_path

      expect(page).to have_current_path(profiles_setup_path)
    end

    it "prevents re-entering setup after completion" do
      user.update!(setup_completed: true)
      sign_in
      visit profiles_setup_path

      expect(page).to have_current_path(root_path)
    end
  end
end
