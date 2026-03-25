# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication" do
  describe "registration" do
    it "creates an account and redirects to setup wizard" do
      visit root_path

      expect(page).to have_text("Create your account to get started")

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      fill_in "Confirm password", with: "password123"
      click_button "Create account"

      expect(page).to have_current_path(emulator_profiles_path)
      expect(User.count).to eq(1)
    end

    it "shows validation errors for mismatched passwords" do
      visit new_registration_path

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      fill_in "Confirm password", with: "wrong"
      click_button "Create account"

      expect(page).to have_text("doesn't match Password")
    end

    it "redirects away if a user already exists" do
      create(:user, setup_completed: true)

      visit new_registration_path

      expect(page).to have_current_path(new_session_path)
    end
  end

  describe "login" do
    let!(:user) { create(:user, username: "admin", password: "password123", setup_completed: true) }

    it "signs in with valid credentials" do
      visit new_session_path

      expect(page).to have_text("Sign in to your vault")

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      click_button "Sign in"

      expect(page).to have_current_path(root_path)
      expect(page).to have_text("Dashboard")
    end

    it "shows an error with invalid credentials" do
      visit new_session_path

      fill_in "Username", with: "admin"
      fill_in "Password", with: "wrongpassword"
      click_button "Sign in"

      expect(page).to have_text("Try another username or password.")
    end

    it "redirects to setup wizard when setup is incomplete" do
      user.update!(setup_completed: false)

      visit new_session_path

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      click_button "Sign in"

      expect(page).to have_current_path(emulator_profiles_path)
    end
  end

  describe "logout" do
    before { create(:user, username: "admin", password: "password123", setup_completed: true) }

    it "signs out and redirects to login page" do
      visit new_session_path

      fill_in "Username", with: "admin"
      fill_in "Password", with: "password123"
      click_button "Sign in"

      expect(page).to have_text("Dashboard")

      click_on "Sign Out"

      expect(page).to have_current_path(new_session_path)
      expect(page).to have_text("Sign in to your vault")
    end
  end

  describe "unauthenticated access" do
    it "redirects to login when not signed in" do
      create(:user)

      visit root_path

      expect(page).to have_current_path(new_session_path)
    end

    it "redirects to registration when no users exist" do
      visit root_path

      expect(page).to have_current_path(new_registration_path)
    end
  end
end
