import { Controller } from "@hotwired/stimulus"

// Handles file downloads without navigating away from the page.
// On iOS standalone/PWA mode, uses the Web Share API to show the
// native share sheet. Falls back to a blob download elsewhere.
export default class extends Controller {
  submit(event) {
    event.preventDefault()

    const form = event.currentTarget
    const triggerEl = form.querySelector('[type="submit"]')
    const method = (form.method || "GET").toUpperCase()

    if (method === "POST") {
      this._download(form.action, triggerEl, "POST", new FormData(form))
    } else {
      const url = new URL(form.action, window.location.origin)
      new FormData(form).forEach((value, key) => url.searchParams.append(key, value))
      this._download(url.toString(), triggerEl)
    }
  }

  click(event) {
    event.preventDefault()

    const anchor = event.currentTarget.closest("a") || event.currentTarget
    const url = anchor.href
    if (url) this._download(url, anchor)
  }

  async _download(url, triggerEl, method = "GET", body = null) {
    if (triggerEl) triggerEl.classList.add("btn-disabled")

    const options = { credentials: "same-origin", method }
    if (method === "POST") {
      options.body = body
      options.headers = { "X-CSRF-Token": document.querySelector('[name="csrf-token"]')?.content || "" }
    }

    try {
      const response = await fetch(url, options)
      if (!response.ok) throw new Error(`Download failed: ${response.status}`)

      const blob = await response.blob()
      const filename = this._extractFilename(response) || "download"

      if (this._isIOSStandalone() && this._canShareFile(blob, filename)) {
        const file = new File([blob], filename, { type: blob.type })
        await navigator.share({ files: [file] })
      } else {
        this._blobDownload(blob, filename)
      }
    } catch (error) {
      if (error.name !== "AbortError") {
        console.error("Download error:", error)
      }
    } finally {
      if (triggerEl) triggerEl.classList.remove("btn-disabled")
    }
  }

  _extractFilename(response) {
    const disposition = response.headers.get("Content-Disposition")
    if (!disposition) return null
    const match = disposition.match(/filename="?([^";]+)"?/)
    return match ? match[1] : null
  }

  _isIOSStandalone() {
    return navigator.standalone === true ||
      window.matchMedia("(display-mode: standalone)").matches &&
      /iPad|iPhone|iPod/.test(navigator.userAgent)
  }

  _canShareFile(blob, filename) {
    if (!navigator.canShare) return false
    const file = new File([blob], filename, { type: blob.type })
    return navigator.canShare({ files: [file] })
  }

  _blobDownload(blob, filename) {
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = filename
    a.style.display = "none"
    document.body.appendChild(a)
    a.click()
    setTimeout(() => {
      a.remove()
      URL.revokeObjectURL(url)
    }, 1000)
  }
}
