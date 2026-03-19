class Api::ApplicationController < ActionController::API
  before_action :authenticate_api_token!

  private def authenticate_api_token!
    token = request.headers["Authorization"]&.delete_prefix("Bearer ")
    token ||= params[:token]
    @current_user = User.find_by(api_token: token)
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
