require "rails_helper"

RSpec.describe UI::EmptyStateComponent, type: :component do
  it "renders a title" do
    render_inline(described_class.new(title: "No games yet"))

    expect(page).to have_css("h3", text: "No games yet")
  end

  it "renders a decorative icon" do
    render_inline(described_class.new(title: "Empty"))

    expect(page).to have_text("✦")
  end

  it "renders an optional description" do
    render_inline(described_class.new(title: "Empty", description: "Add some games to get started."))

    expect(page).to have_css("p", text: "Add some games to get started.")
  end

  it "omits description when not provided" do
    html = render_inline(described_class.new(title: "Empty"))

    expect(html.css("p.opacity-60")).to be_empty
  end

  it "renders an action slot" do
    render_inline(described_class.new(title: "Empty")) do |c|
      c.with_action { "Add Game" }
    end

    expect(page).to have_text("Add Game")
  end
end
