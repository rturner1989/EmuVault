require "rails_helper"

RSpec.describe GameAutoScanJob do
  let(:scan_dir) { Dir.mktmpdir }

  before do
    create(:user, setup_completed: false, scan_enabled: true, scan_interval: :hourly, last_scanned_at: 2.hours.ago)
    create(:emulator_profile, :default_profile,
      name: "RetroArch", platform: :linux, game_system: :gba,
      save_extension: "srm", user_selected: true)
    create(:scan_path, path: scan_dir, game_system: :gba, auto_scan: true)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to)
  end

  after { FileUtils.remove_entry(scan_dir) }

  it "does not import games directly" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now

    expect(Game.count).to eq(0)
  end

  it "stores results as pending_review" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now

    expect(User.first.last_scan_result["status"]).to eq("pending_review")
    expect(User.first.last_scan_result["found"].size).to eq(1)
  end

  it "sends a notification when games are found" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    expect { described_class.perform_now }
      .to change(Noticed::Notification, :count).by(1)
  end

  it "does not send a notification when no games are found" do
    expect { described_class.perform_now }
      .not_to change(Noticed::Notification, :count)
  end

  it "notification message includes game count and review prompt" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
    FileUtils.touch(File.join(scan_dir, "Pokemon.gba"))

    described_class.perform_now

    notification = Noticed::Notification.last
    expect(notification.message).to include("2 new games")
    expect(notification.message).to include("review")
  end

  it "does not create a duplicate notification if an unread scan notification exists" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now
    expect(Noticed::Notification.count).to eq(1)

    User.first.update!(last_scanned_at: 2.hours.ago)
    described_class.perform_now
    expect(Noticed::Notification.count).to eq(1)
  end

  it "creates a new notification after the previous one is read" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now
    Noticed::Notification.last.update!(read_at: Time.current)

    User.first.update!(last_scanned_at: 2.hours.ago)
    described_class.perform_now
    expect(Noticed::Notification.count).to eq(2)
  end
end
