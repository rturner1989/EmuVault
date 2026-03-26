# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Data Export and Import" do
  before do
    create(:user, username: "admin", password: "password123", setup_completed: true)
    visit new_session_path

    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  describe "export" do
    it "shows export button on settings page" do
      visit settings_path

      expect(page).to have_text("Export library")
      expect(page).to have_button("Export")
    end
  end

  describe "import" do
    it "shows import form on settings page" do
      visit settings_path

      expect(page).to have_text("Import library")
      expect(page).to have_button("Import")
    end

    it "shows error when no file is selected" do
      visit settings_path

      click_on "Import"

      expect(page).to have_text("Please select an export file")
    end

    it "shows error for invalid zip file" do
      visit settings_path

      attach_file "file", file_fixture("invalid_export.zip"), make_visible: true
      click_on "Import"

      expect(page).to have_text("Invalid export file")
    end

    context "with a valid export file" do
      before do
        create(:emulator_profile, name: "RetroArch", game_system: :gba, save_extension: "srm")
      end

      it "shows review page with import summary" do
        visit settings_path

        attach_file "file", file_fixture("valid_export.zip"), make_visible: true
        click_on "Import"

        expect(page).to have_text("Review Import")
      end
    end
  end
end
