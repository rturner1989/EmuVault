require "rails_helper"

RSpec.describe Layouts::FlashComponent::Item, type: :component do
  it "renders a notice alert" do
    render_inline(described_class.new(type: :notice, message: "Saved!"))

    expect(page).to have_css("[role='alert']", text: "Saved!")
    expect(page).to have_css(".alert-success")
    expect(page).to have_css("i.fa-solid.fa-circle-check")
  end

  it "renders an alert (error) type" do
    render_inline(described_class.new(type: :alert, message: "Failed!"))

    expect(page).to have_css("[role='alert']", text: "Failed!")
    expect(page).to have_css(".alert-error")
    expect(page).to have_css("i.fa-solid.fa-circle-xmark")
  end

  it "renders a dismiss button" do
    render_inline(described_class.new(type: :notice, message: "Done"))

    expect(page).to have_css("[aria-label='Dismiss']")
  end

  it "includes flash controller data" do
    render_inline(described_class.new(type: :notice, message: "Done"))

    expect(page).to have_css("[data-controller='flash']")
  end

  it "renders a progress bar" do
    render_inline(described_class.new(type: :notice, message: "Done"))

    expect(page).to have_css(".flash-progress")
  end

  it "falls back to notice for unknown types" do
    render_inline(described_class.new(type: :unknown, message: "Hmm"))

    expect(page).to have_css(".alert-success")
  end
end
