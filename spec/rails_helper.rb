# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require_relative '../config/environment'

abort('The Rails environment is running in production mode!') if Rails.env.production?
abort('The Rails environment is running in development mode!') if Rails.env.development?

require 'rspec/rails'
require 'selenium/webdriver'
require 'support/factory_bot'
require 'view_component/test_helpers'

Capybara.register_driver :remote_selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  if ENV['HUB_URL']
    Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV['HUB_URL'], capabilities: [ options ])
  else
    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: [ options ])
  end
end

Capybara.javascript_driver = :remote_selenium
Capybara.default_driver = :remote_selenium

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before do
    ActiveJob::Base.queue_adapter = :test
  end

  config.before(:each, type: :system) do
    Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
    Capybara.server_port = '4000'
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}:3000"
    driven_by :remote_selenium
  end

  config.include Capybara::DSL
  config.include ViewComponent::TestHelpers, type: :component
end
