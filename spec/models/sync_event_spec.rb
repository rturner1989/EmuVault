require "rails_helper"

RSpec.describe SyncEvent do
  subject(:sync_event) { build(:sync_event) }

  describe "associations" do
    it { is_expected.to belong_to(:game_save) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:performed_at) }
  end

  describe "enum" do
    it "defines action with push and pull" do
      expect(described_class.actions.keys).to eq(%w[push pull])
    end

    it "defines status with success and failed" do
      expect(described_class.statuses.keys).to eq(%w[success failed])
    end
  end

  describe "scopes" do
    describe ".recent" do
      it "orders by performed_at descending" do
        old_event = create(:sync_event, performed_at: 1.day.ago)
        new_event = create(:sync_event, performed_at: 1.hour.ago)

        expect(described_class.recent).to eq([ new_event, old_event ])
      end
    end
  end

  describe "#device_type" do
    let(:game_save) { create(:game_save) }

    it "detects phone from mobile user agent" do
      event = create(:sync_event, game_save: game_save, user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS)")

      expect(event.device_type).to eq(:phone)
    end

    it "detects tablet from iPad user agent" do
      event = create(:sync_event, game_save: game_save, user_agent: "Mozilla/5.0 (iPad; CPU OS)")

      expect(event.device_type).to eq(:tablet)
    end

    it "defaults to desktop" do
      event = create(:sync_event, game_save: game_save, user_agent: "Mozilla/5.0 (X11; Linux x86_64)")

      expect(event.device_type).to eq(:desktop)
    end
  end

  describe "#device_label" do
    it "returns human-readable device label" do
      event = create(:sync_event, user_agent: "Mozilla/5.0 (iPhone)")

      expect(event.device_label).to eq("Phone")
    end
  end

  describe "#action_label" do
    it "returns Upload for push" do
      event = create(:sync_event, action: :push)

      expect(event.action_label).to eq("Upload")
    end

    it "returns Download for pull" do
      event = create(:sync_event, action: :pull)

      expect(event.action_label).to eq("Download")
    end
  end

  describe "#action_icon" do
    it "returns up arrow for push" do
      event = create(:sync_event, action: :push)

      expect(event.action_icon).to eq("fa-arrow-up")
    end

    it "returns down arrow for pull" do
      event = create(:sync_event, action: :pull)

      expect(event.action_icon).to eq("fa-arrow-down")
    end
  end

  describe "#performed_at_label" do
    it "formats the timestamp" do
      event = create(:sync_event, performed_at: Time.zone.parse("2026-03-15 14:30"))

      expect(event.performed_at_label).to eq("Mar 15, 2026 at 14:30")
    end
  end

  describe "#game_title" do
    it "returns the game title" do
      game = create(:game, title: "Zelda")
      game_save = create(:game_save, game: game)
      event = create(:sync_event, game_save: game_save)

      expect(event.game_title).to eq("Zelda")
    end
  end

  describe "#game_id" do
    it "returns the game id" do
      game = create(:game, title: "Zelda")
      game_save = create(:game_save, game: game)
      event = create(:sync_event, game_save: game_save)

      expect(event.game_id).to eq(game.id)
    end
  end
end
