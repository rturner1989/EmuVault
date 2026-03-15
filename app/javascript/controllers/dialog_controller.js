import { Controller } from "@hotwired/stimulus"
import A11yDialog from "a11y-dialog"

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

  connect() {
    this.dialog = new A11yDialog(this.containerTarget)
  }

  disconnect() {
    document.body.style.overflow = ""
    this.dialog.destroy()
  }

  open(event) {
    event.preventDefault()
    document.body.style.overflow = "hidden"
    this.dialog.show()
  }

  close(event) {
    event.preventDefault()
    document.body.style.overflow = ""
    this.dialog.hide()
  }

  // Called by Turbo Stream after a successful form submit to close the dialog
  closeOnSuccess() {
    document.body.style.overflow = ""
    this.dialog.hide()
  }
}
