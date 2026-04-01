require "rails_helper"

RSpec.describe GameScanDryRunJob do
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

  it "does not create games" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now(user_id: user.id)

    expect(Game.count).to eq(0)
  end

  it "stores results in user last_scan_result" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now(user_id: user.id)

    result = user.reload.last_scan_result
    expect(result["status"]).to eq("reviewed")
    expect(result["found"].size).to eq(1)
    expect(result["found"].first["title"]).to eq("Zelda")
  end

  it "broadcasts review content via turbo stream" do
    FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

    described_class.perform_now(user_id: user.id)

    expect(Turbo::StreamsChannel).to have_received(:broadcast_update_to).with(
      "scans_#{user.id}",
      target: "scan-review-content",
      html: include("Zelda")
    )
  end
end
