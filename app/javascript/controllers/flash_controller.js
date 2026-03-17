import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 4000 } }

  connect() {
    this.autoTimer = setTimeout(() => this.dismiss(), this.durationValue)
  }

  disconnect() {
    clearTimeout(this.autoTimer)
  }

  dismiss() {
    clearTimeout(this.autoTimer)

    const el = this.element
    el.style.transition = "opacity 300ms ease, transform 300ms ease"
    el.style.opacity = "0"
    el.style.transform = "translateY(-6px)"

    // Collapse height after fade
    setTimeout(() => {
      el.style.transition = "max-height 250ms ease, margin 250ms ease, padding 250ms ease"
      el.style.overflow = "hidden"
      el.style.maxHeight = el.offsetHeight + "px"
      // Force reflow so the transition fires
      el.offsetHeight // eslint-disable-line no-unused-expressions
      el.style.maxHeight = "0"
      el.style.marginTop = "0"
      el.style.marginBottom = "0"
      el.style.paddingTop = "0"
      el.style.paddingBottom = "0"
    }, 300)

    setTimeout(() => el.remove(), 600)
  }
}
