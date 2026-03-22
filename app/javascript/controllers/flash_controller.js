import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 4000 } }
  static targets = ["progress"]

  connect() {
    if (this.hasProgressTarget) {
      this.progressTarget.style.animationDuration = `${this.durationValue}ms`
    }
    this.autoTimer = setTimeout(() => this.dismiss(), this.durationValue)
  }

  disconnect() {
    clearTimeout(this.autoTimer)
  }

  dismiss() {
    clearTimeout(this.autoTimer)

    const element = this.element
    element.style.transition = "opacity 300ms ease, transform 300ms ease"
    element.style.opacity = "0"
    element.style.transform = "translateY(-6px)"

    // Collapse height after fade
    setTimeout(() => {
      element.style.transition = "max-height 250ms ease, margin 250ms ease, padding 250ms ease"
      element.style.overflow = "hidden"
      element.style.maxHeight = element.offsetHeight + "px"
      element.offsetHeight
      element.style.maxHeight = "0"
      element.style.marginTop = "0"
      element.style.marginBottom = "0"
      element.style.paddingTop = "0"
      element.style.paddingBottom = "0"
    }, 300)

    setTimeout(() => element.remove(), 600)
  }
}
