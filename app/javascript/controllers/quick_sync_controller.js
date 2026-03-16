import { Controller } from "@hotwired/stimulus"
import A11yDialog from "a11y-dialog"
import { lockScroll, unlockScroll } from "./scroll_lock"

// Manages the quick sync bottom sheet — triggered from the mobile centre nav button.
// Works identically to the dialog controller but scoped to the app shell wrapper
// so the trigger can live outside the dialog markup.
export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.dialog = new A11yDialog(this.containerTarget)
    this.dialog.on("show", () => {
      lockScroll()
      requestAnimationFrame(() => this.containerTarget.classList.add("dialog--open"))
    })
    this.dialog.on("hide", () => {
      this.containerTarget.classList.remove("dialog--open")
      setTimeout(() => unlockScroll(), 250)
    })
  }

  disconnect() {
    this.containerTarget.classList.remove("dialog--open")
    unlockScroll()
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
}
