# frozen_string_literal: true

class AdminAuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    session_id = request.cookie_jar.signed[:session_id]

    if session_id.present? && Session.exists?(id: session_id)
      @app.call(env)
    else
      [302, { "Location" => "/session/new" }, [""]]
    end
  end
end
