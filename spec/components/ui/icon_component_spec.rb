require "rails_helper"

RSpec.describe UI::IconComponent, type: :component do
  it "renders an i tag with solid style by default" do
    render_inline(described_class.new(name: "fa-house"))

    expect(page).to have_css("i.fa-solid.fa-house.fa-fw")
  end

  it "renders with a custom style" do
    render_inline(described_class.new(name: "fa-bell", style: "fa-regular"))

    expect(page).to have_css("i.fa-regular.fa-bell")
  end

  it "omits fa-fw when fw: false" do
    render_inline(described_class.new(name: "fa-house", fw: false))

    expect(page).to have_css("i.fa-solid.fa-house")
    expect(page).to have_no_css("i.fa-fw")
  end

  it "merges extra classes" do
    render_inline(described_class.new(name: "fa-house", class: "text-primary"))

    expect(page).to have_css("i.fa-solid.fa-house.text-primary")
  end
end
