require "rails_helper"

RSpec.describe UI::LogoComponent, type: :component do
  it "renders the logo with default (md) size" do
    render_inline(described_class.new)

    expect(page).to have_css("img[src='/icon.svg'][width='28'][height='28']")
    expect(page).to have_text("Emu")
    expect(page).to have_text("Vault")
  end

  it "renders sm size" do
    render_inline(described_class.new(size: :sm))

    expect(page).to have_css("img[width='24'][height='24']")
    expect(page).to have_css("span.text-lg")
  end

  it "renders lg size" do
    render_inline(described_class.new(size: :lg))

    expect(page).to have_css("img[width='28'][height='28']")
    expect(page).to have_css("span.text-2xl")
  end
end
