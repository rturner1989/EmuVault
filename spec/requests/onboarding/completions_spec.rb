require "rails_helper"

RSpec.describe "Onboarding::Completions" do
  let(:user) { sign_in(create(:user, setup_completed: false)) }

  before { user }

  describe "POST /onboarding/completion" do
    it "marks setup as completed" do
      post onboarding_completion_path

      expect(user.reload.setup_completed).to be(true)
    end

    it "redirects to root" do
      post onboarding_completion_path

      expect(response).to redirect_to(root_path)
    end

    it "sets the onboarding tour flag" do
      post onboarding_completion_path
      follow_redirect!

      expect(response.body).to include("onboarding")
    end
  end
end
