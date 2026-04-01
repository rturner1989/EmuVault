require "rails_helper"

RSpec.describe GameScanConfirmJob do
  let(:scan_dir) { Dir.mktmpdir }
  let(:user) { create(:user, setup_completed: false) }
  let(:items) do
    [ { "title" => "Zelda", "game_system" => "gba", "rom_path" => "/roms/Zelda.gba", "save_files" => [] } ]
  end

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

  it "imports specified items" do
    described_class.perform_now(items, user_id: user.id)

    expect(Game.count).to eq(1)
    expect(Game.last.title).to eq("Zelda")
  end

  it "broadcasts per-game additions" do
    described_class.perform_now(items, user_id: user.id)

    expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
      "scans_#{user.id}",
      target: "onboarding-games-list",
      html: include("Zelda")
    )
  end
end
