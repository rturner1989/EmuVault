require "rails_helper"

RSpec.describe "Notifications" do
  let(:user) { sign_in }

  before { user }

  describe "GET /notifications" do
    it "renders the notifications list" do
      get notifications_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /notifications/read_mark" do
    it "marks all notifications as read" do
      post read_mark_path

      expect(response).to have_http_status(:ok)
    end
  end
end
