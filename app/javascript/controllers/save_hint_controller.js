import { Controller } from "@hotwired/stimulus"

// Shows the suggested save path when a download profile is selected.
export default class extends Controller {
  static targets = ["select", "hint", "note", "copyBtn"]

  update() {
    const selected = this.selectTarget.selectedOptions[0]
    const path = selected?.dataset?.path

    if (path) {
      this.hintTarget.textContent = path
      if (this.hasNoteTarget) this.noteTarget.classList.remove("hidden")
    } else {
      if (this.hasNoteTarget) this.noteTarget.classList.add("hidden")
    }
  }

  copy() {
    const path = this.hintTarget.textContent
    if (!path) return

    navigator.clipboard.writeText(path).then(() => {
      if (!this.hasCopyBtnTarget) return

      const icon = this.copyBtnTarget.querySelector('i')
      if (!icon) return

      icon.className = 'fa-solid fa-check fa-fw'
      this.copyBtnTarget.classList.add("text-success")
      this.copyBtnTarget.classList.remove("text-muted")

      setTimeout(() => {
        icon.className = 'fa-regular fa-clipboard fa-fw'
        this.copyBtnTarget.classList.remove("text-success")
        this.copyBtnTarget.classList.add("text-muted")
      }, 1500)
    })
  }
}
