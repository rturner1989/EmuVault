require "rails_helper"

RSpec.describe "Games Scan" do
  let(:user) { sign_in }

  before { user }

  describe "POST /game_scan (scan library)" do
    it "enqueues a dry_run scan job" do
      allow(GameScanJob).to receive(:perform_later)

      post game_scan_path,
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(GameScanJob).to have_received(:perform_later).with("dry_run")
    end

    it "opens the review modal with spinner via turbo stream" do
      allow(GameScanJob).to receive(:perform_later)

      post game_scan_path,
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("scan-review-dialog")
      expect(response.body).to include("open_dialog")
      expect(response.body).to include("Scanning")
    end
  end

  describe "POST /game_scan/confirmation (confirm import)" do
    before do
      user.update!(last_scan_result: {
        "status" => "pending_review",
        "found" => [
          { "rom_path" => "/roms/Zelda.gba", "title" => "Zelda", "game_system" => "gba", "save_files" => [] },
          { "rom_path" => "/roms/Pokemon.gba", "title" => "Pokemon", "game_system" => "gba", "save_files" => [] }
        ]
      })
    end

    it "enqueues confirm job with selected items" do
      allow(GameScanJob).to receive(:perform_later)

      post game_scan_confirmation_path,
        params: { selected_roms: [ "/roms/Zelda.gba" ] },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(GameScanJob).to have_received(:perform_later).with("confirm", [
        { "rom_path" => "/roms/Zelda.gba", "title" => "Zelda", "game_system" => "gba", "save_files" => [] }
      ])
    end

    it "closes the review modal via turbo stream" do
      allow(GameScanJob).to receive(:perform_later)

      post game_scan_confirmation_path,
        params: { selected_roms: [ "/roms/Zelda.gba" ] },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("close_dialog")
      expect(response.body).to include("scan-review-dialog")
    end

    it "shows flash with queued count" do
      allow(GameScanJob).to receive(:perform_later)

      post game_scan_confirmation_path,
        params: { selected_roms: [ "/roms/Zelda.gba", "/roms/Pokemon.gba" ] },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("2 games queued for import")
    end

    it "shows queued flash message" do
      allow(GameScanJob).to receive(:perform_later)

      post game_scan_confirmation_path,
        params: { selected_roms: [ "/roms/Zelda.gba" ] },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("queued for import")
    end

    it "shows alert when no games selected" do
      allow(GameScanJob).to receive(:perform_later)

      post game_scan_confirmation_path,
        params: { selected_roms: [] },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("No games selected")
      expect(GameScanJob).not_to have_received(:perform_later)
    end
  end
end
