require "rails_helper"

RSpec.describe UI::BadgeComponent, type: :component do
  it "renders content in a span" do
    render_inline(described_class.new) { "Linux" }

    expect(page).to have_css("span", text: "Linux")
  end

  it "applies default color (comment) and size (sm)" do
    render_inline(described_class.new) { "Tag" }

    expect(page).to have_css("span.badge")
  end

  it "applies a custom color" do
    render_inline(described_class.new(color: :green)) { "Online" }

    expect(page).to have_css("span", text: "Online")
  end

  it "applies a custom size" do
    render_inline(described_class.new(size: :lg)) { "Big" }

    expect(page).to have_css("span", text: "Big")
  end

  it "renders an icon slot" do
    render_inline(described_class.new) do |c|
      c.with_icon(name: "fa-check")
      "Done"
    end

    expect(page).to have_css("i.fa-solid.fa-check")
    expect(page).to have_text("Done")
  end
end
