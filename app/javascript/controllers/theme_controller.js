import { Controller } from "@hotwired/stimulus"
import A11yDialog from "a11y-dialog"
import { lockScroll, unlockScroll } from "./scroll_lock"

export default class extends Controller {
  static values = { current: String }
  static targets = ["dialog"]

  connect() {
    this.saved = false
    this.changed = false
    this.pendingUrl = null
    this.boundBeforeVisit = this.beforeVisit.bind(this)
    document.addEventListener("turbo:before-visit", this.boundBeforeVisit)

    // Reset radio selection to saved theme (Turbo cache may preserve preview state)
    const savedRadio = this.element.querySelector(`input[type="radio"][value="${this.currentValue}"]`)
    if (savedRadio) savedRadio.checked = true
    document.documentElement.setAttribute("data-theme", this.currentValue)
  }

  dialogTargetConnected() {
    this.a11yDialog = new A11yDialog(this.dialogTarget)
    this.a11yDialog.on("show", () => {
      lockScroll()
      requestAnimationFrame(() => this.dialogTarget.classList.add("dialog--open"))
    })
    this.a11yDialog.on("hide", () => {
      this.dialogTarget.classList.remove("dialog--open")
      setTimeout(() => unlockScroll(), 250)
    })
  }

  preview(event) {
    this.changed = event.target.value !== this.currentValue
    document.documentElement.setAttribute("data-theme", event.target.value)
  }

  save() {
    this.saved = true
    this.changed = false
  }

  beforeVisit(event) {
    if (this.changed && !this.saved) {
      event.preventDefault()
      this.pendingUrl = event.detail.url
      this.a11yDialog.show()
    }
  }

  confirmLeaveAndSave() {
    this.a11yDialog.hide()
    this.saved = true
    this.changed = false
    this.element.querySelector("form").requestSubmit()
    setTimeout(() => Turbo.visit(this.pendingUrl), 300)
  }

  cancelLeave() {
    this.pendingUrl = null
    this.a11yDialog.hide()
  }

  disconnect() {
    document.removeEventListener("turbo:before-visit", this.boundBeforeVisit)
    if (!this.saved) {
      document.documentElement.setAttribute("data-theme", this.currentValue)
    }
    if (this.a11yDialog) {
      this.a11yDialog.destroy()
    }
  }
}
