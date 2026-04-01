# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Onboarding" do
  describe "step 1 — select emulators" do
    before do
      create(:emulator_profile, :default_profile, :unselected,
        name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
      create(:emulator_profile, :default_profile, :unselected,
        name: "mGBA", platform: :linux, game_system: :gba, save_extension: "sav")

      visit root_path

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      fill_in "Confirm password", with: "password123"
      click_button "Create account"
    end

    it "shows the onboarding banner at step 1" do
      expect(page).to have_text("Select your emulators")
      expect(page).to have_text("1")
    end

    it "does not show the Next button before selecting profiles" do
      expect(page).to have_no_link("Next: Add Games")
    end

    it "shows empty state when no profiles are selected" do
      expect(page).to have_text("No emulators configured yet")
    end

    it "does not show the page header after deleting all profiles" do
      # Add a profile
      click_on "Add custom profile"
      fill_in "Emulator name", with: "DeSmuME"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "dsv"
      find("[form='new-profile-form'][type='submit']").click
      expect(page).to have_text("DeSmuME")

      # Delete it
      click_on "Remove"
      within("[id*='delete_emulator_profile']:not([aria-hidden])") do
        click_on "Confirm"
      end
      expect(page).to have_text("Profile removed")

      # Should show empty state without the post-setup page header
      expect(page).to have_text("No emulators configured yet")
      expect(page).to have_no_text("Emulator Profiles")
      expect(page).to have_no_text("Your configured emulators by game system")
    end

    it "hides the Next button after adding then deleting all profiles" do
      # Add a profile
      click_on "Add custom profile"
      fill_in "Emulator name", with: "DeSmuME"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "dsv"
      find("[form='new-profile-form'][type='submit']").click
      expect(page).to have_link("Next: Add Games")

      # Delete it
      click_on "Remove"
      within("[id*='delete_emulator_profile']:not([aria-hidden])") do
        click_on "Confirm"
      end
      expect(page).to have_text("Profile removed")

      # Next button should be gone
      expect(page).to have_no_link("Next: Add Games")
    end

    it "adds a custom profile" do
      click_on "Add custom profile"

      expect(page).to have_css("[id='new-profile-dialog']:not([aria-hidden])")

      fill_in "Emulator name", with: "DeSmuME"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "dsv"
      find("[form='new-profile-form'][type='submit']").click

      expect(page).to have_text("Profile added")
      expect(page).to have_text("DeSmuME")
    end

    it "shows validation errors for blank custom profile" do
      click_on "Add custom profile"
      find("[form='new-profile-form'][type='submit']").click

      expect(page).to have_text("can't be blank")
    end

    it "shows the Next button after selecting a profile" do
      click_on "Add custom profile"

      fill_in "Emulator name", with: "DeSmuME"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "dsv"
      find("[form='new-profile-form'][type='submit']").click

      expect(page).to have_text("Profile added")
      expect(page).to have_link("Next: Add Games")
    end

    it "navigates to step 2 via the Next button" do
      click_on "Add custom profile"

      fill_in "Emulator name", with: "DeSmuME"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "dsv"
      find("[form='new-profile-form'][type='submit']").click

      expect(page).to have_link("Next: Add Games")
      click_on "Next: Add Games"

      expect(page).to have_current_path(onboarding_games_path)
      expect(page).to have_text("Add your games")
    end
  end

  describe "step 2 — add games" do
    before do
      visit root_path

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      fill_in "Confirm password", with: "password123"
      click_button "Create account"

      # Add a custom profile to get past step 1
      click_on "Add custom profile"
      fill_in "Emulator name", with: "RetroArch"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "srm"
      find("[form='new-profile-form'][type='submit']").click

      page.has_text?("Profile added") # wait for turbo stream without expect in hook
      click_on "Next: Add Games"
    end

    it "shows the onboarding banner at step 2" do
      expect(page).to have_text("Add your games")
      expect(page).to have_text("2")
    end

    it "shows the Back button to step 1" do
      expect(page).to have_link("Back")
    end

    it "does not show the Complete Setup button before adding games" do
      expect(page).to have_no_link("Complete Setup")
    end

    it "only shows systems with selected emulator profiles" do
      find("details", text: "Add game").click

      expect(page).to have_select("game[system]", with_options: [ "Game Boy Advance" ])
    end

    it "adds a game manually" do
      find("details", text: "Add game").click
      fill_in "Title", with: "Pokemon Emerald"
      select "Game Boy Advance", from: "game[system]"
      click_on "Add Game"

      expect(page).to have_text("Pokemon Emerald added")
      expect(page).to have_text("Pokemon Emerald")
    end

    it "shows the Complete Setup button after adding a game" do
      find("details", text: "Add game").click
      fill_in "Title", with: "Pokemon Emerald"
      select "Game Boy Advance", from: "game[system]"
      find("[form='add-game-form-inline'][type='submit']").click

      expect(page).to have_text("Pokemon Emerald added")
      expect(page).to have_text("Complete Setup")
    end

    it "removes a game via the confirm dialog" do
      find("details", text: "Add game").click
      fill_in "Title", with: "Pokemon Emerald"
      select "Game Boy Advance", from: "game[system]"
      find("[form='add-game-form-inline'][type='submit']").click
      expect(page).to have_text("Pokemon Emerald added")

      find("[aria-label='Remove']").click
      expect(page).to have_text("Remove game?")
      within("[id*='remove_game']:not([aria-hidden])") do
        click_on "Remove"
      end

      expect(page).to have_text("Pokemon Emerald removed")
    end

    it "hides the Complete Setup button after adding then removing all games" do
      find("details", text: "Add game").click
      fill_in "Title", with: "Pokemon Emerald"
      select "Game Boy Advance", from: "game[system]"
      find("[form='add-game-form-inline'][type='submit']").click
      expect(page).to have_text("Complete Setup")

      find("[aria-label='Remove']").click
      within("[id*='remove_game']:not([aria-hidden])") do
        click_on "Remove"
      end
      expect(page).to have_text("Pokemon Emerald removed")

      expect(page).to have_no_text("Complete Setup")
    end

    it "navigates back to step 1" do
      click_on "Back"

      expect(page).to have_current_path(onboarding_emulator_profiles_path)
      expect(page).to have_text("Select your emulators")
    end
  end

  describe "completing setup" do
    before do
      visit root_path

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      fill_in "Confirm password", with: "password123"
      click_button "Create account"

      # Step 1: add profile
      click_on "Add custom profile"
      fill_in "Emulator name", with: "RetroArch"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "srm"
      find("[form='new-profile-form'][type='submit']").click
      page.has_text?("Profile added") # wait for turbo stream without expect in hook
      click_on "Next: Add Games"

      # Step 2: add game
      find("details", text: "Add game").click
      fill_in "Title", with: "Pokemon Emerald"
      select "Game Boy Advance", from: "game[system]"
      click_on "Add Game"
      page.has_text?("Pokemon Emerald added") # wait for turbo stream without expect in hook
    end

    it "completes setup and redirects to the dashboard" do
      click_on "Complete Setup"

      expect(page).to have_current_path(root_path)
      expect(page).to have_text("Dashboard")
    end

    it "prevents returning to onboarding after completion" do
      click_on "Complete Setup"
      expect(page).to have_text("Dashboard")

      visit onboarding_emulator_profiles_path

      expect(page).to have_current_path(root_path)
    end
  end

  describe "URL manipulation during setup" do
    before do
      visit root_path

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      fill_in "Confirm password", with: "password123"
      click_button "Create account"

      page.has_text?("Select your emulators") # wait for redirect without expect in hook
    end

    it "redirects /emulator_profiles to onboarding" do
      visit emulator_profiles_path

      expect(page).to have_current_path(onboarding_emulator_profiles_path)
    end

    it "redirects /games to onboarding" do
      visit games_path

      expect(page).to have_current_path(onboarding_emulator_profiles_path)
    end

    it "redirects /settings to onboarding" do
      visit settings_path

      expect(page).to have_current_path(onboarding_emulator_profiles_path)
    end

    it "redirects /activity to onboarding" do
      visit activity_path

      expect(page).to have_current_path(onboarding_emulator_profiles_path)
    end

    it "redirects the dashboard to onboarding" do
      visit root_path

      expect(page).to have_current_path(onboarding_emulator_profiles_path)
    end
  end
end
