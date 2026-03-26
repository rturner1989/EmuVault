# frozen_string_literal: true

desc "Take screenshots of key pages for the README"
task screenshots: :environment do
  require "playwright"
  require "fileutils"

  output_dir = Rails.root.join("docs/screenshots")
  FileUtils.mkdir_p(output_dir)

  app_host = ENV.fetch("SCREENSHOT_APP_HOST", "http://app:3000")

  user = User.first
  unless user
    puts "No user found. Create one first by visiting the app."
    exit 1
  end

  password = ENV.fetch("SCREENSHOT_PASSWORD") { abort "Set SCREENSHOT_PASSWORD env var" }

  pages = {
    desktop: {
      width: 1400,
      height: 900,
      routes: {
        dashboard: "/",
        games: "/games",
        activity: "/activity",
        emulator_profiles: "/emulator_profiles",
        settings: "/settings"
      }
    },
    mobile: {
      width: 390,
      height: 844,
      routes: {
        dashboard: "/",
        games: "/games",
        activity: "/activity",
        settings: "/settings"
      }
    }
  }

  onboarding_pages = {
    onboarding_step1: { path: "/onboarding/emulator_profiles", width: 1400, height: 900 },
    onboarding_step2: { path: "/onboarding/games", width: 1400, height: 900 }
  }

  Playwright.create(playwright_cli_executable_path: "npx playwright") do |playwright|
    browser = playwright.chromium.launch(headless: true)

    begin
      pages.each do |viewport, config|
        context = browser.new_context(viewport: { width: config[:width], height: config[:height] })
        page = context.new_page

        # Log in
        puts "Logging in as #{user.username}..."
        page.goto("#{app_host}/session/new")
        page.fill("input[name='session[username]']", user.username)
        page.fill("input[name='session[password]']", password)
        page.expect_navigation do
          page.click("button[type='submit']")
        end
        sleep 2
        puts "Current URL after login: #{page.url}"

        config[:routes].each do |name, path|
          page.goto("#{app_host}#{path}")
          page.wait_for_load_state(state: "networkidle")
          sleep 1

          filename = "#{viewport}_#{name}.png"
          filepath = output_dir.join(filename).to_s
          page.screenshot(path: filepath, fullPage: false)
          puts "Saved #{filename}"
        end

        context.close
      end

      # Onboarding screenshots (need a setup-incomplete user)
      onboarding_user = User.find_or_create_by!(username: "screenshot_onboarding") do |u|
        u.password = password
        u.password_confirmation = password
        u.setup_completed = false
      end
      onboarding_user.update!(setup_completed: false)

      # Select some profiles for step 1 to look populated
      EmulatorProfile.where(is_default: true).limit(5).update_all(user_selected: true)

      context = browser.new_context(viewport: { width: 1400, height: 900 })
      page = context.new_page

      page.goto("#{app_host}/session/new")
      page.fill("input[name='session[username]']", onboarding_user.username)
      page.fill("input[name='session[password]']", password)
      page.expect_navigation do
        page.click("button[type='submit']")
      end
      page.wait_for_selector("text=Select your emulators", timeout: 10_000) rescue nil

      onboarding_pages.each do |name, config|
        page.goto("#{app_host}#{config[:path]}")
        page.wait_for_load_state(state: "networkidle")
        sleep 1

        filepath = output_dir.join("#{name}.png").to_s
        page.screenshot(path: filepath, fullPage: false)
        puts "Saved #{name}.png"
      end

      # Clean up onboarding user
      onboarding_user.destroy
      context.close

    ensure
      browser.close
    end

    puts "\nScreenshots saved to #{output_dir}"
  end
end
