import { Controller } from "@hotwired/stimulus"
import { lockScroll, unlockScroll } from "../utils/scroll_lock"

export default class extends Controller {
  static targets = ["backdrop", "overlay", "panel", "frame"]

  connect() {
    this._handleEscape = (event) => {
      if (event.key === "Escape" && this._isOpen) this.close()
    }
    document.addEventListener("keydown", this._handleEscape)
    this._isOpen = false
  }

  disconnect() {
    document.removeEventListener("keydown", this._handleEscape)
  }

  open() {
    this._isOpen = true
    this.backdropTarget.classList.remove("pointer-events-none")
    this.overlayTarget.classList.remove("opacity-0")
    this.overlayTarget.classList.add("opacity-100")
    this.panelTarget.classList.remove("translate-x-full")
    this.panelTarget.classList.add("translate-x-0")
    lockScroll()
    if (this.hasFrameTarget) {
      this.frameTarget.reload()
    }
  }

  close() {
    this._isOpen = false
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("translate-x-0")
    this.panelTarget.classList.add("translate-x-full")
    unlockScroll()

    this.panelTarget.addEventListener("transitionend", () => {
      this.backdropTarget.classList.add("pointer-events-none")
    }, { once: true })
  }

  markAllRead() {
    document.querySelectorAll("[data-notification-badge]").forEach((el) => {
      el.classList.add("hidden")
      el.textContent = ""
    })

    fetch("/notifications/read_mark", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']")?.content || "",
        "Content-Type": "application/json",
      },
    }).then(() => {
      if (this.hasFrameTarget) this.frameTarget.reload()
      this.close()
    })
  }
}
