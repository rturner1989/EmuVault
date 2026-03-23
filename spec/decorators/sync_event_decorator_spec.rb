require "rails_helper"

RSpec.describe SyncEventDecorator do
  let(:game) { create(:game, title: "Zelda") }
  let(:game_save) { create(:game_save, game: game) }

  describe "#device_type" do
    it "detects phone from mobile user agent" do
      event = create(:sync_event, game_save: game_save, user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS)")
      expect(described_class.new(event).device_type).to eq(:phone)
    end

    it "detects tablet from iPad user agent" do
      event = create(:sync_event, game_save: game_save, user_agent: "Mozilla/5.0 (iPad; CPU OS)")
      expect(described_class.new(event).device_type).to eq(:tablet)
    end

    it "defaults to desktop" do
      event = create(:sync_event, game_save: game_save, user_agent: "Mozilla/5.0 (X11; Linux x86_64)")
      expect(described_class.new(event).device_type).to eq(:desktop)
    end
  end

  describe "#device_label" do
    it "returns human-readable device label" do
      event = create(:sync_event, game_save: game_save, user_agent: "Mozilla/5.0 (iPhone)")
      expect(described_class.new(event).device_label).to eq("Phone")
    end
  end

  describe "#action_label" do
    it "returns Upload for push" do
      event = create(:sync_event, game_save: game_save, action: :push)
      expect(described_class.new(event).action_label).to eq("Upload")
    end

    it "returns Download for pull" do
      event = create(:sync_event, game_save: game_save, action: :pull)
      expect(described_class.new(event).action_label).to eq("Download")
    end
  end

  describe "#action_icon" do
    it "returns up arrow for push" do
      event = create(:sync_event, game_save: game_save, action: :push)
      expect(described_class.new(event).action_icon).to eq("fa-arrow-up")
    end

    it "returns down arrow for pull" do
      event = create(:sync_event, game_save: game_save, action: :pull)
      expect(described_class.new(event).action_icon).to eq("fa-arrow-down")
    end
  end

  describe "#performed_at_label" do
    it "formats the timestamp" do
      event = create(:sync_event, game_save: game_save, performed_at: Time.zone.parse("2026-03-15 14:30"))
      expect(described_class.new(event).performed_at_label).to eq("Mar 15, 2026 at 14:30")
    end
  end

  describe "#game_title" do
    it "returns the game title" do
      event = create(:sync_event, game_save: game_save)
      expect(described_class.new(event).game_title).to eq("Zelda")
    end
  end

  describe "#game_id" do
    it "returns the game id" do
      event = create(:sync_event, game_save: game_save)
      expect(described_class.new(event).game_id).to eq(game.id)
    end
  end
end
