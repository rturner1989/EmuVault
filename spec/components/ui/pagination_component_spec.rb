# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::PaginationComponent, type: :component do
  let(:base_path) { "/activity" }
  let(:params) { { sort: "newest" } }

  it "does not render when there is only one page" do
    pagy = Pagy::Offset.new(count: 5, limit: 20, page: 1)
    render_inline(described_class.new(pagy: pagy, base_path: base_path, params: params))

    expect(page).to have_no_css("nav")
  end

  it "renders pagination when there are multiple pages" do
    pagy = Pagy::Offset.new(count: 50, limit: 20, page: 1)
    render_inline(described_class.new(pagy: pagy, base_path: base_path, params: params))

    expect(page).to have_css("nav[aria-label='Pagination']")
    expect(page).to have_css(".join .btn", minimum: 3)
  end

  it "marks the current page as active" do
    pagy = Pagy::Offset.new(count: 50, limit: 20, page: 2)
    render_inline(described_class.new(pagy: pagy, base_path: base_path, params: params))

    expect(page).to have_css(".btn-active", text: "2")
  end

  it "disables the previous button on the first page" do
    pagy = Pagy::Offset.new(count: 50, limit: 20, page: 1)
    render_inline(described_class.new(pagy: pagy, base_path: base_path, params: params))

    expect(page).to have_css("button.btn-disabled .fa-chevron-left")
  end

  it "disables the next button on the last page" do
    pagy = Pagy::Offset.new(count: 50, limit: 20, page: 3)
    render_inline(described_class.new(pagy: pagy, base_path: base_path, params: params))

    expect(page).to have_css("button.btn-disabled .fa-chevron-right")
  end

  it "enables both previous and next on a middle page" do
    pagy = Pagy::Offset.new(count: 50, limit: 20, page: 2)
    render_inline(described_class.new(pagy: pagy, base_path: base_path, params: params))

    expect(page).to have_css("a.join-item .fa-chevron-left")
    expect(page).to have_css("a.join-item .fa-chevron-right")
  end

  it "includes params in page URLs" do
    pagy = Pagy::Offset.new(count: 50, limit: 20, page: 1)
    render_inline(described_class.new(pagy: pagy, base_path: base_path, params: { game_id: 5, sort: "oldest" }))

    expect(page).to have_link("2", href: "/activity?game_id=5&page=2&sort=oldest")
  end

  it "renders the correct number of page buttons" do
    pagy = Pagy::Offset.new(count: 80, limit: 20, page: 1)
    render_inline(described_class.new(pagy: pagy, base_path: base_path, params: params))

    (1..4).each do |num|
      expect(page).to have_css(".join-item", text: num.to_s)
    end
  end
end
