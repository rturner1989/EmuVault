# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cover image" do
  let!(:game) { create(:game, title: "Zelda", system: :gba) }

  let(:cover_image_path) { Rails.root.join("spec/fixtures/files/cover.png").to_s }

  before do
    create(:user, username: "admin", password: "password123", setup_completed: true)
    create(:emulator_profile, name: "RetroArch", platform: :linux, game_system: :gba, save_extension: "srm")
    visit new_session_path
    fill_in "Username", with: "admin"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    page.has_text?("Dashboard")
  end

  def open_edit_and_select_cover
    visit game_path(game)
    click_on "Edit"
    expect(page).to have_text("Cover Image")
    find("input[type='file'][accept*='image']", visible: :all).set(cover_image_path)
    expect(page).to have_css("#crop-cover-dialog:not([aria-hidden])")
    expect(page).to have_css(".cropper-container")
  end

  describe "cropper modal" do
    it "opens the cropper when a file is selected" do
      open_edit_and_select_cover

      expect(page).to have_button("Crop & Use")
      expect(page).to have_button("Cancel")
    end

    it "closes the cropper when Cancel is clicked" do
      open_edit_and_select_cover

      within("#crop-cover-dialog") do
        click_button "Cancel"
      end

      expect(page).to have_css("#crop-cover-dialog[aria-hidden='true']", visible: :all)
      expect(page).to have_text("No file selected")
    end

    it "closes the cropper when Escape is pressed" do
      open_edit_and_select_cover

      page.execute_script("document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }))")

      expect(page).to have_css("#crop-cover-dialog[aria-hidden='true']", visible: :all)
      expect(page).to have_text("No file selected")
    end

    it "does not close the edit modal when Escape closes the cropper" do
      open_edit_and_select_cover

      page.execute_script("document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }))")

      expect(page).to have_css("#crop-cover-dialog[aria-hidden='true']", visible: :all)
      expect(page).to have_css("[id='edit-game-dialog']:not([aria-hidden])")
    end

    it "closes the cropper when clicking outside the panel" do
      open_edit_and_select_cover

      page.execute_script("document.querySelector('#crop-cover-dialog .dialog-overlay').click()")

      expect(page).to have_css("#crop-cover-dialog[aria-hidden='true']", visible: :all)
      expect(page).to have_text("No file selected")
    end

    it "crops and uses the image" do
      open_edit_and_select_cover

      click_button "Crop & Use"

      expect(page).to have_css("#crop-cover-dialog[aria-hidden='true']", visible: :all)
      expect(page).to have_text("cover.webp")
    end

    it "shows a preview after cropping" do
      open_edit_and_select_cover

      click_button "Crop & Use"

      expect(page).to have_css("[data-image-cropper-target='preview']:not(.hidden)")
    end
  end

  describe "uploading a cover image" do
    it "saves a cover image via the edit form" do
      open_edit_and_select_cover

      click_button "Crop & Use"
      expect(page).to have_text("cover.webp")

      find("[form*='edit-game'][type='submit']").click

      expect(page).to have_text("Zelda updated")
      game.reload
      expect(game.cover_image).to be_attached
    end

    it "shows the cover image on the card view" do
      game.cover_image.attach(
        io: File.open(cover_image_path),
        filename: "cover.png",
        content_type: "image/png"
      )

      visit games_path

      within(".grid") do
        expect(page).to have_css("img[alt='Zelda']")
        expect(page).to have_no_css(".fa-gamepad")
      end
    end
  end
end
