require "rails_helper"

RSpec.describe GameScanJob do
  let(:scan_dir) { Dir.mktmpdir }

  before do
    create(:user, setup_completed: false)
    create(:emulator_profile, :default_profile,
      name: "RetroArch", platform: :linux, game_system: :gba,
      save_extension: "srm", user_selected: true)
    create(:scan_path, path: scan_dir, game_system: :gba)
    allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)
    allow(Turbo::StreamsChannel).to receive(:broadcast_append_to)
  end

  after { FileUtils.remove_entry(scan_dir) }

  describe "auto_all mode" do
    it "imports games from scan paths" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      FileUtils.touch(File.join(scan_dir, "Pokemon.gba"))

      described_class.perform_now("auto_all")

      expect(Game.count).to eq(2)
      expect(Game.pluck(:title)).to contain_exactly("Zelda", "Pokemon")
    end

    it "does not create duplicate games" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      create(:game, title: "Zelda", system: :gba)

      described_class.perform_now("auto_all")

      expect(Game.where(title: "Zelda").count).to eq(1)
    end

    it "broadcasts per-game additions" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto_all")

      expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
        "scans_#{User.first.id}",
        target: "onboarding-games-list",
        html: include("Zelda")
      )
    end

    it "clears onboarding scan spinner on completion" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto_all")

      expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to).with(
        "scans_#{User.first.id}",
        target: "scan-progress",
        html: ""
      )
    end

    it "broadcasts flash message on completion" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto_all")

      expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
        "scans_#{User.first.id}",
        target: "flash-container",
        html: include("1 game imported")
      )
    end

    it "broadcasts banner update with Complete Setup on completion" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto_all")

      expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to).with(
        "scans_#{User.first.id}",
        target: "onboarding-banner",
        html: include("Complete Setup")
      )
    end

    it "sets scan status to completed" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto_all")

      expect(User.first.last_scan_result["status"]).to eq("completed")
    end

    it "reports no games found when scan path is empty" do
      described_class.perform_now("auto_all")

      expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
        "scans_#{User.first.id}",
        target: "flash-container",
        html: include("No new games found")
      )
    end
  end

  describe "dry_run mode" do
    it "does not create games" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("dry_run")

      expect(Game.count).to eq(0)
    end

    it "stores results in user last_scan_result" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("dry_run")

      result = User.first.last_scan_result
      expect(result["status"]).to eq("reviewed")
      expect(result["found"].size).to eq(1)
      expect(result["found"].first["title"]).to eq("Zelda")
    end

    it "does not broadcast" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("dry_run")

      expect(Turbo::StreamsChannel).not_to have_received(:broadcast_append_to)
    end
  end

  describe "auto mode" do
    before do
      User.first.update!(scan_enabled: true, scan_interval: :hourly, last_scanned_at: 2.hours.ago)
      create(:scan_path, path: scan_dir, game_system: :gba, auto_scan: true)
    end

    it "does not import games directly" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto")

      expect(Game.count).to eq(0)
    end

    it "stores results as pending_review" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto")

      expect(User.first.last_scan_result["status"]).to eq("pending_review")
      expect(User.first.last_scan_result["found"].size).to eq(1)
    end

    it "sends a notification when games are found" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      expect { described_class.perform_now("auto") }
        .to change(Noticed::Notification, :count).by(1)
    end

    it "does not send a notification when no games are found" do
      expect { described_class.perform_now("auto") }
        .not_to change(Noticed::Notification, :count)
    end

    it "notification message includes game count and review prompt" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      FileUtils.touch(File.join(scan_dir, "Pokemon.gba"))

      described_class.perform_now("auto")

      notification = Noticed::Notification.last
      expect(notification.message).to include("2 new games")
      expect(notification.message).to include("review")
    end

    it "does not create a duplicate notification if an unread scan notification exists" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto")
      expect(Noticed::Notification.count).to eq(1)

      User.first.update!(last_scanned_at: 2.hours.ago)
      described_class.perform_now("auto")
      expect(Noticed::Notification.count).to eq(1)
    end

    it "creates a new notification after the previous one is read" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      described_class.perform_now("auto")
      Noticed::Notification.last.update!(read_at: Time.current)

      User.first.update!(last_scanned_at: 2.hours.ago)
      described_class.perform_now("auto")
      expect(Noticed::Notification.count).to eq(2)
    end
  end

  describe "confirm mode" do
    let(:items) do
      [ { "title" => "Zelda", "game_system" => "gba", "rom_path" => "/roms/Zelda.gba", "save_files" => [] } ]
    end

    it "imports specified items" do
      described_class.perform_now("confirm", items)

      expect(Game.count).to eq(1)
      expect(Game.last.title).to eq("Zelda")
    end

    it "broadcasts per-game additions" do
      described_class.perform_now("confirm", items)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
        "scans_#{User.first.id}",
        target: "onboarding-games-list",
        html: include("Zelda")
      )
    end
  end
end
