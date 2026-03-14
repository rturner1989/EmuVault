Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(Rails.root.join("config/sidekiq_scheduler.yml"))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end

require "sidekiq/web"
Sidekiq::Web.use(Rack::Auth::Basic, "EmuVault") do |username, password|
  admin_email = ENV.fetch("ADMIN_EMAIL", nil)
  admin_password = ENV.fetch("ADMIN_PASSWORD", nil)
  admin_email.present? &&
    ActiveSupport::SecurityUtils.secure_compare(username, admin_email) &&
    ActiveSupport::SecurityUtils.secure_compare(password, admin_password.to_s)
end
