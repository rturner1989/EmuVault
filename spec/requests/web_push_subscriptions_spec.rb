require "rails_helper"

RSpec.describe "WebPushSubscriptions" do
  let(:user) { sign_in }

  before { user }

  describe "POST /web_push_subscriptions" do
    it "creates a subscription" do
      post web_push_subscriptions_path, params: {
        web_push_subscription: {
          endpoint: "https://push.example.com/sub/1",
          p256dh: SecureRandom.base64(65),
          auth: SecureRandom.base64(16)
        }
      }

      expect(response).to have_http_status(:created)
      expect(WebPushSubscription.count).to eq(1)
    end

    it "returns existing subscription for same endpoint" do
      create(:web_push_subscription, user: user, endpoint: "https://push.example.com/sub/1")

      post web_push_subscriptions_path, params: {
        web_push_subscription: {
          endpoint: "https://push.example.com/sub/1",
          p256dh: SecureRandom.base64(65),
          auth: SecureRandom.base64(16)
        }
      }

      expect(response).to have_http_status(:created)
      expect(WebPushSubscription.count).to eq(1)
    end
  end

  describe "DELETE /web_push_subscriptions/:id" do
    it "destroys the subscription by endpoint" do
      subscription = create(:web_push_subscription, user: user)

      delete web_push_subscription_path(subscription), params: { endpoint: subscription.endpoint }

      expect(response).to have_http_status(:no_content)
      expect(WebPushSubscription.exists?(subscription.id)).to be(false)
    end
  end
end
