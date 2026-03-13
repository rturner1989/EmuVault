import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "frame"]

  open() {
    this.backdropTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    if (this.hasFrameTarget) {
      this.frameTarget.reload()
    }
  }

  close() {
    this.backdropTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  markAllRead() {
    // Immediately clear the badge without waiting for ActionCable
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
