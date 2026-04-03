import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "bulkBar", "bulkForm", "count", "selectAll"]
  static values = { selectedText: { type: String, default: "%{count} selected" } }

  toggle() {
    this.updateState()
  }

  toggleAll(event) {
    const checked = event.target.checked
    this.checkboxTargets.forEach(cb => cb.checked = checked)
    this.updateState()
  }

  updateState() {
    const checked = this.checkboxTargets.filter(cb => cb.checked)
    const count = checked.length

    if (count > 0) {
      this.bulkBarTarget.classList.remove("hidden")
      this.countTarget.textContent = this.selectedTextValue.replace("%{count}", count)
    } else {
      this.bulkBarTarget.classList.add("hidden")
    }

    if (this.hasSelectAllTarget) {
      const total = this.checkboxTargets.length
      this.selectAllTarget.checked = count === total
      this.selectAllTarget.indeterminate = count > 0 && count < total
    }
  }

  submitBulk(event) {
    event.preventDefault()
    const form = this.bulkFormTarget
    // Remove any previously added hidden inputs
    form.querySelectorAll("input[name='profile_ids[]']").forEach(el => el.remove())
    // Add one hidden input per checked checkbox
    this.checkboxTargets.filter(cb => cb.checked).forEach(cb => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "profile_ids[]"
      input.value = cb.value
      form.appendChild(input)
    })
    form.requestSubmit()
  }

  clearSelection() {
    this.checkboxTargets.forEach(cb => cb.checked = false)
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = false
      this.selectAllTarget.indeterminate = false
    }
    this.bulkBarTarget.classList.add("hidden")
  }
}
