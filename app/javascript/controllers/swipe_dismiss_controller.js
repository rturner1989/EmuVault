import { Controller } from "@hotwired/stimulus"

// Enables swipe-down-to-close on mobile bottom sheet dialogs.
// Attach to the dialog-content wrapper. The first child element is
// treated as the sheet that gets translated on drag.
export default class extends Controller {
  connect() {
    this.sheet = this.element.firstElementChild
    if (!this.sheet) return

    this.onTouchStart = this.onTouchStart.bind(this)
    this.onTouchMove = this.onTouchMove.bind(this)
    this.onTouchEnd = this.onTouchEnd.bind(this)

    this.element.addEventListener("touchstart", this.onTouchStart, { passive: true })
    this.element.addEventListener("touchmove", this.onTouchMove, { passive: false })
    this.element.addEventListener("touchend", this.onTouchEnd, { passive: true })
  }

  disconnect() {
    this.element.removeEventListener("touchstart", this.onTouchStart)
    this.element.removeEventListener("touchmove", this.onTouchMove)
    this.element.removeEventListener("touchend", this.onTouchEnd)
  }

  onTouchStart(event) {
    // Allow drag from the handle or the card header area
    if (!event.target.closest(".dialog-handle-wrapper") && !event.target.closest(".dialog-card > :first-child")) return

    this.dragging = true
    this.startY = event.touches[0].clientY
    this.currentY = 0
    this.sheet.style.transition = "none"
  }

  onTouchMove(event) {
    if (!this.dragging) return

    this.currentY = Math.max(0, event.touches[0].clientY - this.startY)
    this.sheet.style.transform = `translateY(${this.currentY}px)`

    if (this.currentY > 0) event.preventDefault()
  }

  onTouchEnd() {
    if (!this.dragging) return
    this.dragging = false

    this.sheet.style.transition = ""

    if (this.currentY > this.sheet.offsetHeight * 0.3) {
      this.sheet.style.transform = "translateY(100%)"
      const container = this.element.closest(".dialog-container")
      const closeBtn = container?.querySelector("[data-action*='dialog#close'], [data-a11y-dialog-hide]")
      if (closeBtn) {
        setTimeout(() => {
          closeBtn.click()
          this.sheet.style.transform = ""
          this.sheet.style.transition = ""
        }, 150)
      }
    } else {
      this.sheet.style.transform = ""
    }

    this.currentY = 0
  }
}
