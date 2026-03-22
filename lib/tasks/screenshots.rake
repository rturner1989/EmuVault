# frozen_string_literal: true

desc "Take screenshots of key pages for the README"
task screenshots: :environment do
  require "selenium/webdriver"
  require "fileutils"

  output_dir = Rails.root.join("tmp/screenshots")
  FileUtils.mkdir_p(output_dir)

  hub_url = ENV.fetch("HUB_URL", "http://selenium-hub:4444/wd/hub")
  # Selenium browser connects to the app — use the Docker service name
  # so the Chrome node in the selenium container can reach the app container
  app_host = "http://#{ENV.fetch("SCREENSHOT_APP_HOST", "app")}:3000"

  browser = ENV.fetch("SCREENSHOT_BROWSER", "firefox").to_sym

  options = case browser
  when :chrome
    opts = Selenium::WebDriver::Chrome::Options.new
    opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-features=HttpsUpgrades,HttpsFirstBalancedMode,HttpsFirstModeV2,HttpsFirstMode")
    opts
  when :firefox
    opts = Selenium::WebDriver::Firefox::Options.new
    opts.add_argument("-headless")
    opts.add_preference("security.mixed_content.block_active_content", false)
    opts
  end

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

  # Ensure a user exists
  user = User.first
  unless user
    puts "No user found. Create one first by visiting the app."
    exit 1
  end

  driver = Selenium::WebDriver.for(:remote, url: hub_url, capabilities: [options])
  puts "Using #{browser} browser"

  begin
    # Log in
    puts "Navigating to: #{app_host}/session/new"
    driver.navigate.to("#{app_host}/session/new")
    sleep 2
    puts "Current URL: #{driver.current_url}"
    puts "Page title: #{driver.title}"

    password = ENV.fetch("SCREENSHOT_PASSWORD") { abort "Set SCREENSHOT_PASSWORD env var" }

    # Save debug screenshot if login page has an error
    if driver.title.include?("Exception")
      driver.save_screenshot(output_dir.join("debug_error.png").to_s)
      puts "Error page detected — saved debug_error.png"
      puts "Page source (first 500 chars): #{driver.page_source[0..500]}"
    end

    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    username_field = wait.until { driver.find_element(:css, "input[name='session[username]']") }
    username_field.send_keys(user.username)
    driver.find_element(:css, "input[name='session[password]']").send_keys(password)
    driver.find_element(:css, "input[type='submit'], button[type='submit']").click
    sleep 2
    puts "Logged in. Current URL: #{driver.current_url}"

    pages.each do |viewport, config|
      driver.manage.window.resize_to(config[:width], config[:height])

      config[:routes].each do |name, path|
        driver.navigate.to("#{app_host}#{path}")
        sleep 2

        filename = "#{viewport}_#{name}.png"
        filepath = output_dir.join(filename)
        driver.save_screenshot(filepath.to_s)
        puts "Saved #{filename}"
      end
    end

    puts "\nScreenshots saved to #{output_dir}"
  ensure
    driver.quit
  end
end
