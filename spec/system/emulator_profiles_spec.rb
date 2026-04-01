# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Emulator Profiles" do
  before do
    create(:user, username: "admin", password: "password123", setup_completed: true)
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "profiles index" do
    before do
      create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
      create(:emulator_profile, name: "Delta", platform: :ios, game_system: :gba, save_extension: "sav")
      visit emulator_profiles_path
    end

    it "shows profiles grouped by system" do
      expect(page).to have_text("Game Boy Advance")
      expect(page).to have_text("RetroArch")
      expect(page).to have_text("Delta")
    end
  end

  describe "add from library modal" do
    before do
      create(:emulator_profile, :default_profile, :unselected,
        name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
      create(:emulator_profile, :default_profile, :unselected,
        name: "Snes9x", platform: :linux, game_system: :snes, save_extension: "srm")
      create(:emulator_profile, name: "Delta", platform: :ios, game_system: :gba, save_extension: "sav")
      visit emulator_profiles_path
    end

    it "opens the library modal" do
      click_on "Add from library"

      expect(page).to have_css("[id='library-modal']:not([aria-hidden])")
      expect(page).to have_text("Add from library")
    end

    it "closes the library modal via the X button" do
      click_on "Add from library"
      expect(page).to have_css("[id='library-modal']:not([aria-hidden])")

      find("[id='library-modal'] [aria-label='Close']").click

      expect(page).to have_css("[id='library-modal'][aria-hidden='true']", visible: :all)
    end
  end

  describe "custom profile creation" do
    before { visit emulator_profiles_path }

    it "opens the new profile modal" do
      click_on "Add custom profile"

      expect(page).to have_css("[id='new-profile-dialog']:not([aria-hidden])")
    end

    it "shows validation errors when fields are blank" do
      click_on "Add custom profile"
      find("[form='new-profile-form'][type='submit']").click

      expect(page).to have_text("can't be blank")
    end

    it "creates a profile successfully" do
      click_on "Add custom profile"

      fill_in "Emulator name", with: "mGBA"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "sav"
      find("[form='new-profile-form'][type='submit']").click

      expect(page).to have_text("Profile added")
      expect(page).to have_text("mGBA")
    end

    it "submits successfully after fixing validation errors" do
      click_on "Add custom profile"

      # Submit blank — expect errors
      find("[form='new-profile-form'][type='submit']").click
      expect(page).to have_text("can't be blank")

      # Fill in and resubmit
      fill_in "Emulator name", with: "mGBA"
      find("[id='new-profile-dialog'] select[name*='platform']").select("Linux")
      find("[id='new-profile-dialog'] select[name*='game_system']").select("Game Boy Advance")
      fill_in "Save extension (without dot)", with: "sav"
      find("[form='new-profile-form'][type='submit']").click

      expect(page).to have_text("Profile added")
      expect(page).to have_text("mGBA")
    end
  end

  describe "editing a profile" do
    let!(:profile) { create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm") }

    before { visit emulator_profiles_path }

    it "opens the edit modal" do
      click_on "Edit"

      expect(page).to have_css("[id='edit_emulator_profile_#{profile.id}']:not([aria-hidden])")
      expect(page).to have_field("Emulator name", with: "RetroArch")
    end

    it "shows validation errors when name is cleared" do
      click_on "Edit"
      fill_in "Emulator name", with: ""
      find("[form='edit_form_emulator_profile_#{profile.id}'][type='submit']").click

      expect(page).to have_text("can't be blank")
    end

    it "updates a profile successfully" do
      click_on "Edit"
      fill_in "Emulator name", with: "RetroArch Updated"
      find("[form='edit_form_emulator_profile_#{profile.id}'][type='submit']").click

      expect(page).to have_text("Profile updated")
      expect(page).to have_text("RetroArch Updated")
    end

    it "submits successfully after fixing validation errors" do
      click_on "Edit"

      # Clear and submit — expect errors
      fill_in "Emulator name", with: ""
      find("[form='edit_form_emulator_profile_#{profile.id}'][type='submit']").click
      expect(page).to have_text("can't be blank")

      # Fix and resubmit
      fill_in "Emulator name", with: "RetroArch Fixed"
      find("[form='edit_form_emulator_profile_#{profile.id}'][type='submit']").click

      expect(page).to have_text("Profile updated")
      expect(page).to have_text("RetroArch Fixed")
    end
  end

  describe "default profile restrictions" do
    before do
      create(:emulator_profile, :default_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
      visit emulator_profiles_path
    end

    it "does not show the Edit button for default profiles" do
      expect(page).to have_text("RetroArch")
      expect(page).to have_no_button("Edit")
    end
  end

  describe "deleting a profile" do
    before do
      create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
      visit emulator_profiles_path
    end

    it "shows the confirm dialog" do
      click_on "Remove"

      expect(page).to have_text("Delete profile?")
    end

    it "cancels the deletion" do
      click_on "Remove"
      expect(page).to have_text("Delete profile?")

      within("[id*='delete_emulator_profile']:not([aria-hidden])") do
        click_on "Cancel"
      end

      expect(page).to have_text("RetroArch")
    end

    it "confirms and deletes the profile" do
      click_on "Remove"
      expect(page).to have_text("Delete profile?")

      within("[id*='delete_emulator_profile']:not([aria-hidden])") do
        click_on "Confirm"
      end

      expect(page).to have_text("Profile removed")
      expect(page).to have_no_text("RetroArch")
    end
  end

  describe "deleting a profile in use" do
    before do
      profile = create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
      create(:game, title: "Zelda", system: :gba)
      visit emulator_profiles_path
    end

    it "shows the remove button as disabled" do
      expect(page).to have_css("[title='Remove all Game Boy Advance games first']")
    end
  end

  describe "multi-select and bulk delete" do
    before do
      create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
      create(:emulator_profile, name: "Delta", platform: :ios, game_system: :gba, save_extension: "sav")
      visit emulator_profiles_path
    end

    it "shows the bulk action bar when a profile is selected" do
      first("[data-profile-select-target='checkbox']").check

      expect(page).to have_text("1 selected")
      expect(page).to have_button("Delete selected")
    end

    it "selects all profiles with the select-all checkbox" do
      first("[data-profile-select-target='checkbox']").check
      expect(page).to have_text("1 selected")

      find("[data-profile-select-target='selectAll']").check

      expect(page).to have_text("2 selected")
    end

    it "deselects all profiles" do
      first("[data-profile-select-target='checkbox']").check
      expect(page).to have_text("1 selected")

      click_on "Deselect all"

      expect(page).to have_no_text("selected")
    end

    it "bulk deletes selected profiles" do
      all("[data-profile-select-target='checkbox']").each(&:check)
      expect(page).to have_text("2 selected")

      click_on "Delete selected"

      expect(page).to have_text("removed")
      expect(page).to have_no_text("RetroArch")
      expect(page).to have_no_text("Delta")
    end
  end
end
