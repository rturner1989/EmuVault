require "rails_helper"

RSpec.describe "EmulatorProfiles" do
  let(:user) { sign_in }

  before { user }

  describe "GET /emulator_profiles" do
    it "renders selected profiles grouped by system" do
      create(:emulator_profile, name: "RetroArch", game_system: :snes, user_selected: true)

      get emulator_profiles_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("RetroArch")
    end

    it "does not show unselected profiles" do
      create(:emulator_profile, name: "Hidden", game_system: :snes, user_selected: false)

      get emulator_profiles_path

      expect(response.body).not_to include("Hidden")
    end
  end

  describe "POST /emulator_profiles" do
    let(:valid_params) do
      {
        emulator_profile: {
          name: "Custom Emu",
          platform: "linux",
          game_system: "snes",
          save_extension: "sav",
          default_save_path: "/saves"
        }
      }
    end

    it "creates a custom profile with user_selected true" do
      post emulator_profiles_path, params: valid_params,
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      profile = EmulatorProfile.last
      expect(profile.name).to eq("Custom Emu")
      expect(profile.user_selected).to be(true)
      expect(profile.is_default).to be(false)
    end

    it "rejects invalid params" do
      post emulator_profiles_path, params: {
        emulator_profile: { name: "", platform: "", game_system: "", save_extension: "" }
      }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /emulator_profiles/:id" do
    let(:profile) { create(:emulator_profile, name: "Old Name") }

    it "updates the profile" do
      patch emulator_profile_path(profile), params: {
        emulator_profile: { name: "New Name" }
      }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(profile.reload.name).to eq("New Name")
    end
  end

  describe "DELETE /emulator_profiles/:id" do
    it "deletes a custom profile" do
      profile = create(:emulator_profile, is_default: false)

      delete emulator_profile_path(profile),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(EmulatorProfile.exists?(profile.id)).to be(false)
    end

    it "deselects a default profile instead of deleting" do
      profile = create(:emulator_profile, :default_profile, user_selected: true)

      delete emulator_profile_path(profile),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(profile.reload.user_selected).to be(false)
      expect(EmulatorProfile.exists?(profile.id)).to be(true)
    end

    it "blocks deletion when profile is in use" do
      profile = create(:emulator_profile, game_system: :snes)
      create(:game, system: :snes)

      delete emulator_profile_path(profile),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(EmulatorProfile.exists?(profile.id)).to be(true)
    end
  end

  describe "POST /emulator_profiles/bulk_destroy" do
    it "bulk deletes custom profiles" do
      profiles = create_list(:emulator_profile, 3, is_default: false)

      post emulator_profiles_bulk_destroy_path, params: { profile_ids: profiles.map(&:id) },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(EmulatorProfile.where(id: profiles.map(&:id))).to be_empty
    end

    it "skips profiles that are in use" do
      profile = create(:emulator_profile, game_system: :snes)
      create(:game, system: :snes)

      post emulator_profiles_bulk_destroy_path, params: { profile_ids: [ profile.id ] },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(EmulatorProfile.exists?(profile.id)).to be(true)
    end
  end
end
