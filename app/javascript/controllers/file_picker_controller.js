import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "filename"]

  update() {
    const file = this.inputTarget.files[0]
    this.filenameTarget.textContent = file ? file.name : "No file selected"
  }
}
