PgHero::Engine.middleware.use(Rack::Auth::Basic, "EmuVault") do |username, password|
  admin_email = ENV.fetch("ADMIN_EMAIL", nil)
  admin_password = ENV.fetch("ADMIN_PASSWORD", nil)
  admin_email.present? &&
    ActiveSupport::SecurityUtils.secure_compare(username, admin_email) &&
    ActiveSupport::SecurityUtils.secure_compare(password, admin_password.to_s)
end
