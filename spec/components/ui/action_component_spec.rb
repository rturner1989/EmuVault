require "rails_helper"

RSpec.describe UI::ActionComponent, type: :component do
  describe "rendering as a button" do
    it "renders a button by default (no href)" do
      render_inline(described_class.new) { "Click me" }

      expect(page).to have_css("button", text: "Click me")
    end

    it "renders with type submit" do
      render_inline(described_class.new(type: :submit)) { "Save" }

      expect(page).to have_css("button[type='submit']", text: "Save")
    end

    it "renders disabled state" do
      render_inline(described_class.new(disabled: true)) { "Nope" }

      expect(page).to have_css("button[disabled]", text: "Nope")
      expect(page).to have_css("button.cursor-not-allowed")
    end
  end

  describe "rendering as a link" do
    it "renders an anchor when href is provided" do
      render_inline(described_class.new(href: "/games")) { "Games" }

      expect(page).to have_link("Games", href: "/games")
    end

    it "renders with target blank" do
      render_inline(described_class.new(href: "/pghero", target: :_blank)) { "PgHero" }

      expect(page).to have_css("a[target='_blank']")
    end
  end

  describe "rendering as a form action" do
    it "renders a button_to when href and method are provided" do
      render_inline(described_class.new(href: "/session", method: :delete)) { "Sign Out" }

      expect(page).to have_css("form[action='/session']")
      expect(page).to have_css("input[name='_method'][value='delete']", visible: false)
      expect(page).to have_button("Sign Out")
    end
  end

  describe "icon slots" do
    it "renders a leading icon" do
      render_inline(described_class.new) do |a|
        a.with_leading_icon(name: "fa-plus")
        "Add"
      end

      expect(page).to have_css("i.fa-solid.fa-plus")
      expect(page).to have_text("Add")
    end

    it "renders a trailing icon" do
      render_inline(described_class.new) do |a|
        a.with_trailing_icon(name: "fa-arrow-right")
        "Next"
      end

      expect(page).to have_text("Next")
      expect(page).to have_css("i.fa-solid.fa-arrow-right")
    end
  end

  describe "variants" do
    it "applies primary variant" do
      render_inline(described_class.new(variant: :primary)) { "Go" }

      expect(page).to have_css("button.btn.btn-primary")
    end

    it "applies danger variant" do
      render_inline(described_class.new(variant: :danger)) { "Delete" }

      expect(page).to have_css("button.btn.btn-error")
    end

    it "applies ghost variant" do
      render_inline(described_class.new(variant: :ghost)) { "Cancel" }

      expect(page).to have_css("button.btn.btn-ghost")
    end
  end

  describe "sizes" do
    it "applies xs size" do
      render_inline(described_class.new(size: :xs)) { "Tiny" }

      expect(page).to have_css("button.btn-xs")
    end

    it "applies sm size" do
      render_inline(described_class.new(size: :sm)) { "Small" }

      expect(page).to have_css("button.btn-sm")
    end
  end
end
