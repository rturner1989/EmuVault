import { Controller } from "@hotwired/stimulus"
import A11yDialog from "a11y-dialog"
import { lockScroll, unlockScroll } from "../utils/scroll_lock"

// Wraps a11y-dialog for Turbo-compatible modal dialogs.
//
// Usage:
//   %div{ data: { controller: "dialog" } }
//     %button{ data: { action: "dialog#open" } } Open
//     %div{ data: { dialog_target: "container" }, id: "my-dialog", aria: { hidden: "true" } }
//       %div.dialog-overlay{ data: { action: "click->dialog#close" } }
//       %div.dialog-content{ role: "document" }
//         %button{ data: { action: "dialog#close" } } ✕
//         = yield
export default class extends Controller {
  static targets = ["container"]
  static values = { autoOpen: Boolean }

  connect() {
    this.dialog = new A11yDialog(this.containerTarget)
    this.containerTarget.addEventListener("dialog:close", () => this.dialog.hide())
    this.containerTarget.addEventListener("dialog:open", () => this.dialog.show())

    // Hook into a11y-dialog events so Escape key, backdrop click, and button
    // close all go through the same animation path.
    this.dialog.on("show", () => {
      lockScroll()
      requestAnimationFrame(() => this.containerTarget.classList.add("dialog--open"))
      this.containerTarget.querySelectorAll("turbo-frame[src]").forEach(frame => frame.reload())
    })

    // Reset scroll position when turbo frame content updates inside the dialog
    this.containerTarget.addEventListener("turbo:frame-load", () => {
      const scrollable = this.containerTarget.querySelector(".overflow-y-auto")
      if (scrollable) scrollable.scrollTop = 0
    })

    this.dialog.on("hide", () => {
      this.containerTarget.classList.remove("dialog--open")
      this._resetForms()
      setTimeout(() => unlockScroll(), 250)
    })

    // Belt-and-suspenders: a11y-dialog's keydown listener is scoped to the
    // container element, so ESC can silently fail if focus drifts outside it.
    // This document-level handler ensures ESC always closes the dialog.
    this._handleEscape = (event) => {
      if (event.key === "Escape" && this.dialog.shown) this.dialog.hide()
    }
    document.addEventListener("keydown", this._handleEscape)

    if (this.autoOpenValue) this.dialog.show()
  }

  disconnect() {
    this.containerTarget.classList.remove("dialog--open")
    unlockScroll()
    document.removeEventListener("keydown", this._handleEscape)
    this.dialog.destroy()
  }

  open(event) {
    event.preventDefault()
    this.dialog.show()
  }

  close(event) {
    event.preventDefault()
    this.dialog.hide()
  }

  // Called by Turbo Stream after a successful form submit to close the dialog
  closeOnSuccess() {
    this.dialog.hide()
  }

  _resetForms() {
    this.containerTarget.querySelectorAll("form").forEach(form => {
      form.reset()
      form.querySelectorAll("input:not([type=hidden])").forEach(input => { input.value = "" })
      form.querySelectorAll("select").forEach(select => { select.selectedIndex = 0 })
      form.querySelectorAll(".field_with_errors").forEach(wrapper => {
        wrapper.replaceWith(...wrapper.childNodes)
      })
      form.querySelectorAll("span.error").forEach(el => el.remove())
    })
  }
}
