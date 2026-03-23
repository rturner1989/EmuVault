require "rails_helper"

RSpec.describe GameSaveForm do
  let(:game) { create(:game) }
  let(:file) do
    tempfile = Tempfile.new(["save", ".srm"])
    tempfile.write("save data")
    tempfile.rewind
    Rack::Test::UploadedFile.new(tempfile.path, "application/octet-stream", true, original_filename: "save.srm")
  end
  let(:request) { instance_double(ActionDispatch::Request, remote_ip: "127.0.0.1", user_agent: "RSpec") }

  describe "validations" do
    it "requires a file" do
      form = described_class.new(file: nil)

      expect(form).not_to be_valid
      expect(form.errors[:file]).to be_present
    end

    it "is valid with a file" do
      form = described_class.new(file: file)

      expect(form).to be_valid
    end
  end

  describe ".model_name" do
    it "returns GameSave for form routing" do
      expect(described_class.model_name.name).to eq("GameSave")
    end
  end

  describe "#save" do
    it "creates a game save with checksum" do
      form = described_class.new(file: file)

      expect(form.save(game: game, request: request)).to be(true)
      expect(game.game_saves.count).to eq(1)
      expect(game.game_saves.last.checksum).to be_present
    end

    it "creates a sync event" do
      form = described_class.new(file: file)
      form.save(game: game, request: request)

      event = SyncEvent.last
      expect(event.action).to eq("push")
      expect(event.status).to eq("success")
      expect(event.ip_address).to eq("127.0.0.1")
    end

    it "associates an emulator profile when provided" do
      profile = create(:emulator_profile)
      form = described_class.new(file: file, emulator_profile_id: profile.id)
      form.save(game: game, request: request)

      expect(game.game_saves.last.emulator_profile).to eq(profile)
    end

    it "returns false without a file" do
      form = described_class.new(file: nil)

      expect(form.save(game: game, request: request)).to be(false)
    end

    it "exposes the created game_save" do
      form = described_class.new(file: file)
      form.save(game: game, request: request)

      expect(form.game_save).to be_a(GameSave)
      expect(form.game_save).to be_persisted
    end
  end
end
