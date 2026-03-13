import { Controller } from "@hotwired/stimulus"

// Shows the suggested save path when a download profile is selected.
export default class extends Controller {
  static targets = ["select", "hint"]

  update() {
    const selected = this.selectTarget.selectedOptions[0]
    const path = selected?.dataset?.path

    if (path) {
      this.hintTarget.textContent = `Save to: ${path}`
      this.hintTarget.classList.remove("hidden")
    } else {
      this.hintTarget.classList.add("hidden")
    }
  }
}
