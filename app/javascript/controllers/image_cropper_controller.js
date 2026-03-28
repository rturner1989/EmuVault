import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

export default class extends Controller {
  static targets = ["input", "filename", "preview"]
  static values = { aspectRatio: { type: Number, default: 3 / 4 } }

  connect () {
    this.cropper = null
    this.originalFile = null
    this.modal = null
    this.imageEl = null
  }

  disconnect () {
    this.destroyCropper()
    this.removeModal()
  }

  select () {
    this.inputTarget.click()
  }

  fileSelected () {
    const file = this.inputTarget.files[0]
    if (!file) return

    this.originalFile = file

    const reader = new FileReader()
    reader.onload = (e) => {
      this.createModal()
      this.imageEl.src = e.target.result
      this.imageEl.onload = () => this.initCropper()
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
        this.previewTarget.src = URL.createObjectURL(blob)
        this.previewTarget.classList.remove("hidden")
      }

      this.closeModal()
    }, "image/webp", 0.9)
  }

  cancel () {
    this.inputTarget.value = ""
    this.filenameTarget.textContent = "No file selected"
    this.closeModal()
  }

  createModal () {
    this.removeModal()

    this.imageEl = this.buildElement("img", "w-full block", { maxHeight: "100%" })
    this.overlay = this.buildElement("div", "absolute inset-0 bg-black transition-opacity duration-250 ease-out opacity-0")
    this.panel = this.buildPanel()
    this.modal = this.buildElement("div", "fixed inset-0 flex items-center justify-center", { zIndex: "80" })

    this.modal.append(this.overlay, this.panel)
    this.bindModalEvents()

    document.body.appendChild(this.modal)
    document.body.style.overflow = "hidden"

    requestAnimationFrame(() => {
      this.overlay.classList.replace("opacity-0", "opacity-70")
      this.panel.classList.replace("opacity-0", "opacity-100")
      this.panel.style.transform = "translateY(0) scale(1)"
    })
  }

  buildPanel () {
    const panel = this.buildElement(
      "div",
      "relative bg-base-100 rounded-lg border-2 border-base-300 p-4 mx-4 w-full transition-all duration-250 ease-out opacity-0",
      { maxWidth: "42rem", transform: "translateY(6px) scale(0.98)" }
    )

    const heading = this.buildElement("h3", "text-base font-semibold mb-3")
    heading.textContent = "Crop Cover Image"

    const cropperContainer = this.buildElement("div", "", { maxHeight: "65vh", overflow: "hidden" })
    cropperContainer.appendChild(this.imageEl)

    panel.append(heading, cropperContainer, this.buildFooter())
    return panel
  }

  buildFooter () {
    const footer = this.buildElement("div", "flex justify-end gap-2 mt-4")

    const cancelBtn = this.buildButton("Cancel", "btn btn-ghost btn-sm", "cancel")
    const confirmBtn = this.buildButton("Crop & Use", "btn btn-primary btn-sm", "confirm")

    footer.append(cancelBtn, confirmBtn)
    return footer
  }

  buildElement (tag, className, styles = {}) {
    const el = document.createElement(tag)
    if (className) el.className = className
    Object.assign(el.style, styles)
    return el
  }

  buildButton (text, className, action) {
    const btn = this.buildElement("button", className)
    btn.type = "button"
    btn.textContent = text
    btn.dataset.action = action
    return btn
  }

  bindModalEvents () {
    this.modal.addEventListener("click", (e) => {
      if (e.target.matches("[data-action='cancel']")) this.cancel()
      if (e.target.matches("[data-action='confirm']")) this.confirm()
      if (e.target === this.overlay) this.cancel()
    })

    this.escHandler = (e) => {
      if (e.key === "Escape") {
        e.stopPropagation()
        e.preventDefault()
        this.cancel()
      }
    }
    document.addEventListener("keydown", this.escHandler, true)
  }

  closeModal () {
    this.destroyCropper()

    if (!this.modal) {
      this.removeModal()
      return
    }

    this.overlay.classList.replace("opacity-70", "opacity-0")
    this.panel.classList.replace("opacity-100", "opacity-0")
    this.panel.style.transform = "translateY(6px) scale(0.98)"

    this.panel.addEventListener("transitionend", () => this.removeModal(), { once: true })
  }

  removeModal () {
    if (this.escHandler) {
      document.removeEventListener("keydown", this.escHandler, true)
      this.escHandler = null
    }

    if (this.modal) {
      this.modal.remove()
      this.modal = null
      this.imageEl = null
      document.body.style.overflow = ""
    }
  }

  destroyCropper () {
    if (this.cropper) {
      this.cropper.destroy()
      this.cropper = null
    }
  }
}
