require "rails_helper"

RSpec.describe UI::ConfirmComponent, type: :component do
  let(:default_attrs) do
    {
      id: "confirm-delete",
      title: "Delete game?",
      message: "This action cannot be undone.",
      url: "/games/1"
    }
  end

  it "renders a trigger button" do
    render_inline(described_class.new(**default_attrs))

    expect(page).to have_text("Remove")
  end

  it "renders the confirmation message" do
    render_inline(described_class.new(**default_attrs))

    expect(page).to have_text("This action cannot be undone.")
  end

  it "renders a confirm button" do
    render_inline(described_class.new(**default_attrs))

    expect(page).to have_button("Confirm")
  end

  it "renders with custom trigger and confirm labels" do
    render_inline(described_class.new(**default_attrs, trigger_label: "Delete", confirm_label: "Yes, delete"))

    expect(page).to have_text("Delete")
    expect(page).to have_button("Yes, delete")
  end

  it "renders a trigger icon when provided" do
    render_inline(described_class.new(**default_attrs, trigger_icon: "fa-trash"))

    expect(page).to have_css("i.fa-solid.fa-trash")
  end

  it "uses delete method by default" do
    render_inline(described_class.new(**default_attrs))

    expect(page).to have_css("input[name='_method'][value='delete']", visible: false)
  end

  it "wraps in a ModalComponent" do
    render_inline(described_class.new(**default_attrs))

    expect(page).to have_css("#confirm-delete[aria-hidden='true']")
    expect(page).to have_text("Delete game?")
  end
end
