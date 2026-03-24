# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require_relative '../config/environment'

abort('The Rails environment is running in production mode!') if Rails.env.production?
abort('The Rails environment is running in development mode!') if Rails.env.development?

require 'rspec/rails'
require 'support/factory_bot'
require 'view_component/test_helpers'

VIDEO_DIR = Rails.root.join("tmp/playwright_videos")
FileUtils.mkdir_p(VIDEO_DIR)

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: :chromium,
    headless: true)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :playwright

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before do
    ActiveJob::Base.queue_adapter = :test
  end

  # Playwright video handling
  #
  # Videos are recorded via the driver's on_save_screenrecord callback.
  # After each system test, the callback decides what to keep based on metadata:
  #   video: :always  — keep video regardless of pass/fail
  #   video: false    — never keep video
  #   (default)       — keep on failure only
  #
  # Usage:
  #   RSpec.describe "Login", type: :system, video: :always do
  #   it "signs in", video: false do
  config.before(:each, type: :system) do |example|
    driven_by :playwright

    video_mode = example.metadata[:video]
    page.driver.on_save_screenrecord do |video_path|
      keep = case video_mode
      when :always then true
      when false then false
      else example.exception.present?
      end

      if keep
        named_path = VIDEO_DIR.join("#{example.full_description.parameterize}.webm")
        FileUtils.mv(video_path, named_path)
      else
        FileUtils.rm_f(video_path)
      end
    end
  end

  config.include Capybara::DSL
  config.include ViewComponent::TestHelpers, type: :component
end
