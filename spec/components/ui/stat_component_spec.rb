require "rails_helper"

RSpec.describe UI::StatComponent, type: :component do
  it "renders title and value" do
    render_inline(described_class.new(title: "Games", value: 42))

    expect(page).to have_text("Games")
    expect(page).to have_css(".stat-value", text: "42")
  end

  it "renders a description" do
    render_inline(described_class.new(title: "Games", value: 5, description: "in your library"))

    expect(page).to have_css(".stat-desc", text: "in your library")
  end

  it "applies value_color class" do
    render_inline(described_class.new(title: "Errors", value: 3, value_color: "text-error"))

    expect(page).to have_css(".stat-value.text-error", text: "3")
  end

  it "renders an icon slot" do
    render_inline(described_class.new(title: "Games", value: 10)) do |c|
      c.with_icon(name: "fa-gamepad")
    end

    expect(page).to have_css("i.fa-solid.fa-gamepad")
  end

  it "renders an action slot with defaults" do
    render_inline(described_class.new(title: "Games", value: 10)) do |c|
      c.with_action(href: "/games")
    end

    expect(page).to have_link("View all", href: "/games")
    expect(page).to have_css("i.fa-solid.fa-arrow-right")
  end

  it "renders an action slot with custom label" do
    render_inline(described_class.new(title: "Games", value: 10)) do |c|
      c.with_action(href: "/games", label: "See all")
    end

    expect(page).to have_link("See all", href: "/games")
  end
end
