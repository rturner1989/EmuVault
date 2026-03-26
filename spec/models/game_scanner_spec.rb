require "rails_helper"

RSpec.describe GameScanner do
  subject(:scanner) { described_class.new }

  let(:scan_dir) { Dir.mktmpdir }

  before do
    create(:emulator_profile, :default_profile,
      name: "RetroArch", platform: :linux, game_system: :gba,
      save_extension: "srm", user_selected: true)
    create(:scan_path, path: scan_dir, game_system: :gba)
  end

  after { FileUtils.remove_entry(scan_dir) }

  describe "#collect" do
    it "discovers ROMs in scan paths" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      FileUtils.touch(File.join(scan_dir, "Pokemon.gba"))

      result = scanner.collect(ScanPath.ordered)

      expect(result["found"].size).to eq(2)
      expect(result["found"].map { |f| f["title"] }).to contain_exactly("Zelda", "Pokemon")
    end

    it "skips games already in the library" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      create(:game, title: "Zelda", system: :gba)

      result = scanner.collect(ScanPath.ordered)

      expect(result["found"]).to be_empty
      expect(result["already_in_lib"]).to eq(1)
    end

    it "reports skipped paths that do not exist" do
      create(:scan_path, path: "/nonexistent/path", game_system: :gba)

      result = scanner.collect(ScanPath.ordered)

      expect(result["skipped_paths"].size).to eq(1)
      expect(result["skipped_paths"].first["path"]).to eq("/nonexistent/path")
    end

    it "ignores files with non-ROM extensions" do
      FileUtils.touch(File.join(scan_dir, "readme.txt"))
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      result = scanner.collect(ScanPath.ordered)

      expect(result["found"].size).to eq(1)
    end

    it "does not create any database records" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      expect { scanner.collect(ScanPath.ordered) }.not_to change(Game, :count)
    end
  end

  describe "#import_all" do
    it "creates games for discovered ROMs" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      FileUtils.touch(File.join(scan_dir, "Pokemon.gba"))

      result = scanner.import_all(ScanPath.ordered)

      expect(result["added"]).to eq(2)
      expect(Game.pluck(:title)).to contain_exactly("Zelda", "Pokemon")
    end

    it "skips existing games" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      create(:game, title: "Zelda", system: :gba)

      result = scanner.import_all(ScanPath.ordered)

      expect(result["added"]).to eq(0)
      expect(result["skipped"]).to eq(1)
    end

    it "does not create duplicates" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))

      scanner.import_all(ScanPath.ordered)
      scanner.import_all(ScanPath.ordered)

      expect(Game.where(title: "Zelda").count).to eq(1)
    end

    it "yields each imported game" do
      FileUtils.touch(File.join(scan_dir, "Zelda.gba"))
      FileUtils.touch(File.join(scan_dir, "Pokemon.gba"))

      titles = []
      scanner.import_all(ScanPath.ordered) { |game| titles << game.title }

      expect(titles).to contain_exactly("Zelda", "Pokemon")
    end

    it "titleizes filenames" do
      FileUtils.touch(File.join(scan_dir, "legend_of-zelda.gba"))

      scanner.import_all(ScanPath.ordered)

      expect(Game.last.title).to eq("Legend Of Zelda")
    end
  end

  describe "#import_items" do
    let(:items) do
      [
        { "title" => "Zelda", "game_system" => "gba", "rom_path" => "/roms/Zelda.gba", "save_files" => [] },
        { "title" => "Pokemon", "game_system" => "gba", "rom_path" => "/roms/Pokemon.gba", "save_files" => [] }
      ]
    end

    it "creates games from the item list" do
      result = scanner.import_items(items)

      expect(result["added"]).to eq(2)
      expect(Game.pluck(:title)).to contain_exactly("Zelda", "Pokemon")
    end

    it "yields each imported game" do
      titles = []
      scanner.import_items(items) { |game| titles << game.title }

      expect(titles).to contain_exactly("Zelda", "Pokemon")
    end

    it "does not create duplicates" do
      create(:game, title: "Zelda", system: :gba)

      result = scanner.import_items(items)

      expect(result["added"]).to eq(2)
      expect(Game.where(title: "Zelda").count).to eq(1)
    end
  end
end
