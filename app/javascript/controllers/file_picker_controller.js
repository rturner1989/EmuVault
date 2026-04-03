import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "filename"]
  static values = { noFileText: { type: String, default: "No file selected" } }

  update() {
    const file = this.inputTarget.files[0]
    this.filenameTarget.textContent = file ? file.name : this.noFileTextValue
  }
}
