require "rails_helper"

RSpec.describe GameScanImportAllJob do
  let(:scan_dir) { Dir.mktmpdir }
  let(:user) { create(:user, setup_completed: false) }

  before do
    user
    create(:emulator_profile, :default_profile,
      name: "RetroArch", platform: :linux, game_system: :gba,
      save_extension: "srm", user_selected: true)
    create(:scan_path, path: scan_dir, game_system: :gba)
    allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)
    allow(Turbo::StreamsChannel).to receive(:broadcast_append_to)
  end

  after { FileUtils.remove_entry(scan_dir) }

  it "imports games from scan paths" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
    FileUtils.touch(File.join(scan_dir, "Pokemon.gba"))

    described_class.perform_now(user_id: user.id)

    expect(Game.count).to eq(2)
    expect(Game.pluck(:title)).to contain_exactly("Zelda", "Pokemon")
  end

  it "does not create duplicate games" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
    create(:game, title: "Zelda", system: :gba)

    described_class.perform_now(user_id: user.id)

    expect(Game.where(title: "Zelda").count).to eq(1)
  end

  it "broadcasts per-game additions" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now(user_id: user.id)

    expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
      "scans_#{user.id}",
      target: "onboarding-games-list",
      html: include("Zelda")
    )
  end

  it "clears onboarding scan spinner on completion" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now(user_id: user.id)

    expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to).with(
      "scans_#{user.id}",
      target: "scan-progress",
      html: ""
    )
  end

  it "broadcasts flash message on completion" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now(user_id: user.id)

    expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
      "scans_#{user.id}",
      target: "flash-container",
      html: include("1 game imported")
    )
  end

  it "broadcasts banner update with Complete Setup on completion" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now(user_id: user.id)

    expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to).with(
      "scans_#{user.id}",
      target: "onboarding-banner",
      html: include("Complete Setup")
    )
  end

  it "sets scan status to completed" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now(user_id: user.id)

    expect(user.reload.last_scan_result["status"]).to eq("completed")
  end

  it "reports no games found when scan path is empty" do
    described_class.perform_now(user_id: user.id)

    expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
      "scans_#{user.id}",
      target: "flash-container",
      html: include("No new games found")
    )
  end
end
