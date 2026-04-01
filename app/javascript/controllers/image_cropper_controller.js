import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"
import A11yDialog from "a11y-dialog"

export default class extends Controller {
  static targets = ["input", "filename", "preview"]
  static values = {
    aspectRatio: { type: Number, default: 3 / 4 },
    dialogId: { type: String, default: "crop-cover-dialog" }
  }

  connect () {
    this.cropper = null
    this.originalFile = null

    const form = this.element.closest("form")
    if (form) {
      form.addEventListener("reset", () => {
        this.filenameTarget.textContent = "No file selected"
        this.revokePreview()
        if (this.hasPreviewTarget) this.previewTarget.classList.add("hidden")
      })
    }
  }

  ensureDialog () {
    if (this.a11yDialog) return

    const dialogEl = document.getElementById(this.dialogIdValue)
    if (!dialogEl) return

    this.imageEl = dialogEl.querySelector("[data-cropper-image]")
    this.dialogEl = dialogEl
    this.a11yDialog = new A11yDialog(dialogEl)
    this.a11yDialog.on("show", () => {
      dialogEl.classList.add("dialog--open")
      requestAnimationFrame(() => window.scrollTo(0, this.scrollY))
    })
    this.a11yDialog.on("hide", () => {
      dialogEl.classList.remove("dialog--open")
      requestAnimationFrame(() => window.scrollTo(0, this.scrollY))
      this.destroyCropper()
      if (!this.confirmed) {
        this.inputTarget.value = ""
        this.filenameTarget.textContent = "No file selected"
        this.revokePreview()
      }
      this.confirmed = false
    })

    dialogEl.addEventListener("click", (e) => {
      const action = e.target.closest("[data-cropper-action]")?.dataset.cropperAction
      if (action === "confirm") this.confirm()
      if (action === "cancel") this.cancel()
    })

    this._handleEscape = (e) => {
      if (e.key === "Escape" && this.a11yDialog.shown) {
        e.stopImmediatePropagation()
        this.cancel()
      }
    }
    document.addEventListener("keydown", this._handleEscape, true)
  }

  disconnect () {
    this.destroyCropper()
    this.revokePreview()
    if (this._handleEscape) document.removeEventListener("keydown", this._handleEscape, true)
    this.a11yDialog?.destroy()
  }

  select () {
    this.inputTarget.click()
  }

  fileSelected () {
    const file = this.inputTarget.files[0]
    if (!file) return

    this.ensureDialog()
    this.originalFile = file

    const reader = new FileReader()
    reader.onload = (e) => {
      this.imageEl.src = e.target.result
      this.imageEl.onload = () => this.initCropper()
      this.scrollY = window.scrollY
      this.a11yDialog.show()
    }
    reader.readAsDataURL(file)
  }

  initCropper () {
    this.destroyCropper()
    this.cropper = new Cropper(this.imageEl, {
      aspectRatio: this.aspectRatioValue,
      viewMode: 1,
      autoCropArea: 1,
      responsive: true,
      restore: false,
      guides: true,
      center: true,
      highlight: false,
      background: false
    })
  }

  confirm () {
    if (!this.cropper) return

    const canvas = this.cropper.getCroppedCanvas({
      width: 600,
      height: 800
    })

    canvas.toBlob((blob) => {
      const fileName = this.originalFile.name.replace(/\.[^.]+$/, ".webp")
      const croppedFile = new File([blob], fileName, { type: "image/webp" })

      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(croppedFile)
      this.inputTarget.files = dataTransfer.files

      this.filenameTarget.textContent = fileName

      if (this.hasPreviewTarget) {
        if (this.previewTarget.src.startsWith("blob:")) {
          URL.revokeObjectURL(this.previewTarget.src)
        }
        this.previewTarget.src = URL.createObjectURL(blob)
        this.previewTarget.classList.remove("hidden")
      }

      this.confirmed = true
      this.a11yDialog.hide()
    }, "image/webp", 0.9)
  }

  cancel () {
    this.a11yDialog.hide()
  }

  destroyCropper () {
    if (this.cropper) {
      this.cropper.destroy()
      this.cropper = null
    }
  }

  revokePreview () {
    if (this.hasPreviewTarget && this.previewTarget.src.startsWith("blob:")) {
      URL.revokeObjectURL(this.previewTarget.src)
    }
  }
}
