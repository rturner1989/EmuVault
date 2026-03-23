require "rails_helper"

RSpec.describe UI::ModalComponent, type: :component do
  describe "managed mode (default)" do
    it "renders with dialog controller" do
      render_inline(described_class.new(id: "test-modal", title: "Test")) do |modal|
        modal.with_trigger { "Open" }
        modal.with_body { "Content" }
      end

      expect(page).to have_css("[data-controller='dialog']")
      expect(page).to have_css("#test-modal[aria-hidden='true']")
      expect(page).to have_text("Open")
      expect(page).to have_text("Content")
      expect(page).to have_text("Test")
    end

    it "renders a close button" do
      render_inline(described_class.new(id: "test-modal", title: "Test")) do |modal|
        modal.with_trigger { "Open" }
        modal.with_body { "Content" }
      end

      expect(page).to have_css("[aria-label='Close']")
    end

    it "auto-adds Cancel button when footer is provided" do
      render_inline(described_class.new(id: "test-modal", title: "Test")) do |modal|
        modal.with_trigger { "Open" }
        modal.with_body { "Content" }
        modal.with_footer { "Save" }
      end

      expect(page).to have_text("Cancel")
      expect(page).to have_text("Save")
    end

    it "renders a subtitle" do
      render_inline(described_class.new(id: "test-modal", title: "Test", subtitle: "Subtitle text")) do |modal|
        modal.with_trigger { "Open" }
        modal.with_body { "Content" }
      end

      expect(page).to have_text("Subtitle text")
    end
  end

  describe "unmanaged mode" do
    it "renders without dialog controller when container_data is provided" do
      render_inline(described_class.new(id: "test-modal", title: "Test", container_data: { foo_target: "bar" })) do |modal|
        modal.with_body { "Content" }
      end

      expect(page).to have_no_css("[data-controller='dialog']")
      expect(page).to have_css("#test-modal[data-foo-target='bar']")
    end

    it "does not auto-add Cancel button in unmanaged mode" do
      render_inline(described_class.new(id: "test-modal", title: "Test", container_data: { foo: "bar" })) do |modal|
        modal.with_body { "Content" }
        modal.with_footer { "Done" }
      end

      expect(page).to have_no_text("Cancel")
      expect(page).to have_text("Done")
    end
  end

  describe "bottom sheet variant" do
    it "applies bottom-sheet class" do
      html = render_inline(described_class.new(id: "sheet", title: "Sheet", variant: :bottom_sheet)) do |modal|
        modal.with_trigger { "Open" }
        modal.with_body { "Content" }
      end

      expect(html.css(".dialog-content--bottom")).to be_present
    end
  end
end
