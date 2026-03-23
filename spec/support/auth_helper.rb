module AuthHelper
  def sign_in(user = nil)
    user ||= create(:user)
    post session_path, params: { session: { username: user.username, password: "password123" } }
    user
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
