require "rails_helper"

RSpec.describe UI::PageHeaderComponent, type: :component do
  it "renders the title" do
    render_inline(described_class.new(title: "Games"))

    expect(page).to have_css("h1", text: "Games")
  end

  it "renders an optional subtitle" do
    render_inline(described_class.new(title: "Games", subtitle: "Manage your library"))

    expect(page).to have_css("h1", text: "Games")
    expect(page).to have_css("p", text: "Manage your library")
  end

  it "omits subtitle when not provided" do
    render_inline(described_class.new(title: "Games"))

    expect(page).to have_no_css("p")
  end

  it "renders action slots" do
    render_inline(described_class.new(title: "Games")) do |c|
      c.with_action { "Add Game" }
    end

    expect(page).to have_text("Add Game")
  end
end
