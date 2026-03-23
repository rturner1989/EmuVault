require "rails_helper"

RSpec.describe UI::CardComponent, type: :component do
  it "renders content" do
    render_inline(described_class.new) { "Card body" }

    expect(page).to have_text("Card body")
  end

  it "renders a header slot" do
    render_inline(described_class.new) do |c|
      c.with_header { "Title" }
      c.with_body { "Body" }
    end

    expect(page).to have_text("Title")
    expect(page).to have_text("Body")
  end

  it "renders a footer slot" do
    render_inline(described_class.new) do |c|
      c.with_body { "Body" }
      c.with_footer { "Footer" }
    end

    expect(page).to have_text("Footer")
  end

  it "renders footer_actions" do
    render_inline(described_class.new) do |c|
      c.with_body { "Body" }
      c.with_footer_action { "Action 1" }
      c.with_footer_action { "Action 2" }
    end

    expect(page).to have_text("Action 1")
    expect(page).to have_text("Action 2")
  end

  it "applies sm padding" do
    html = render_inline(described_class.new(padding: :sm)) do |c|
      c.with_header { "Title" }
      c.with_body { "Body" }
    end

    expect(html.css(".px-4")).to be_present
  end

  it "applies md padding by default" do
    html = render_inline(described_class.new) do |c|
      c.with_header { "Title" }
      c.with_body { "Body" }
    end

    expect(html.css(".px-5")).to be_present
  end

  it "applies scrollable class" do
    html = render_inline(described_class.new(scrollable: true)) do |c|
      c.with_body { "Scrollable content" }
    end

    expect(html.css(".overflow-y-auto")).to be_present
  end
end
