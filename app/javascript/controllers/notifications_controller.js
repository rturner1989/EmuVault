import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "overlay", "panel", "frame"]

  open() {
    this.backdropTarget.classList.remove("pointer-events-none")
    this.overlayTarget.classList.remove("opacity-0")
    this.overlayTarget.classList.add("opacity-100")
    this.panelTarget.classList.remove("translate-x-full")
    this.panelTarget.classList.add("translate-x-0")
    document.body.style.overflow = "hidden"
    if (this.hasFrameTarget) {
      this.frameTarget.reload()
    }
  }

  close() {
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("translate-x-0")
    this.panelTarget.classList.add("translate-x-full")
    document.body.style.overflow = ""

    this.panelTarget.addEventListener("transitionend", () => {
      this.backdropTarget.classList.add("pointer-events-none")
    }, { once: true })
  }

  markAllRead() {
    document.querySelectorAll("[data-notification-badge]").forEach((el) => {
      el.classList.add("hidden")
      el.textContent = ""
    })

    fetch("/notifications/mark_all_read", {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']")?.content || "",
        "Content-Type": "application/json",
      },
    }).then(() => {
      if (this.hasFrameTarget) this.frameTarget.reload()
    })
  }
}
