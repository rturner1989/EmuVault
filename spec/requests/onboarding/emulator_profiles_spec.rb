require "rails_helper"

RSpec.describe "Onboarding::EmulatorProfiles" do
  let(:user) { sign_in(create(:user, setup_completed: false)) }

  before { user }

  describe "GET /onboarding/emulator_profiles" do
    it "renders the emulator selection step" do
      get onboarding_emulator_profiles_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Select your emulators")
    end

    it "shows the Next button when profiles are selected" do
      create(:emulator_profile, user_selected: true)

      get onboarding_emulator_profiles_path

      expect(response.body).to include("Next: Add Games")
    end

    it "does not show the Next button when no profiles are selected" do
      get onboarding_emulator_profiles_path

      expect(response.body).not_to include("Next: Add Games")
    end

    it "redirects to root when setup is already complete" do
      user.update!(setup_completed: true)

      get onboarding_emulator_profiles_path

      expect(response).to redirect_to(root_path)
    end
  end
end
