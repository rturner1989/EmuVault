require "rails_helper"

RSpec.describe Layouts::FlashComponent, type: :component do
  it "renders the container with id flash-container" do
    render_inline(described_class.new(flash: {}))

    expect(page).to have_css("#flash-container")
  end

  it "renders empty when no flash messages" do
    render_inline(described_class.new(flash: {}))

    expect(page).to have_no_css("[role='alert']")
  end

  it "renders flash messages" do
    flash = { notice: "Game saved.", alert: "Something went wrong." }
    render_inline(described_class.new(flash: flash))

    expect(page).to have_text("Game saved.")
    expect(page).to have_text("Something went wrong.")
  end
end
