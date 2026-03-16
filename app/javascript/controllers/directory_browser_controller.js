import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "browser", "list", "currentPath", "upButton", "shortcuts"]
  static values  = { current: String }

  // Toggle the browser panel open/closed
  toggle() {
    if (this.browserTarget.hidden) {
      this.browserTarget.hidden = false
      this.loadPath(this.inputTarget.value.trim() || "/")
    } else {
      this.browserTarget.hidden = true
    }
  }

  // Navigate into a directory (called from button data-action)
  navigate(event) {
    event.stopPropagation()
    this.loadPath(event.currentTarget.dataset.path)
  }

  // Write the current path into the text input and close the browser
  select(event) {
    event.stopPropagation()
    this.inputTarget.value = this.currentValue
    this.browserTarget.hidden = true
  }

  // ── private ──────────────────────────────────────────────────────────────

  loadPath(path) {
    this.currentValue = path
    this.currentPathTarget.textContent = path

    // Update the "up" button target
    const parent = this.parentOf(path)
    this.upButtonTarget.dataset.path = parent
    this.upButtonTarget.disabled     = path === "/"

    fetch(`/directory_browser?path=${encodeURIComponent(path)}`)
      .then(r => r.json())
      .then(data => {
        if (data.error) {
          this.listTarget.innerHTML = this.errorHTML(data.error)
        } else {
          this.renderShortcuts(data.shortcuts || [])
          this.renderEntries(data.entries)
        }
      })
      .catch(() => {
        this.listTarget.innerHTML = this.errorHTML("Could not read directory")
      })
  }

  renderShortcuts(shortcuts) {
    if (!this.hasShortcutsTarget) return
    this.shortcutsTarget.innerHTML = shortcuts.map(p => `
      <button
        type="button"
        class="text-xs px-2 py-0.5 rounded border border-drac-current text-drac-comment hover:border-drac-fg hover:text-drac-fg transition-colors cursor-pointer"
        data-action="click->directory-browser#navigate"
        data-path="${this.escapeAttr(p)}">${this.escapeHTML(p)}</button>
    `).join("")
  }

  renderEntries(entries) {
    if (entries.length === 0) {
      this.listTarget.innerHTML =
        '<p class="text-xs text-drac-comment px-3 py-3 italic">No subdirectories</p>'
      return
    }

    this.listTarget.innerHTML = entries.map(entry => `
      <button
        type="button"
        class="w-full flex items-center gap-2 px-3 py-2 text-left text-sm text-drac-fg hover:bg-drac-current transition-colors"
        data-action="click->directory-browser#navigate"
        data-path="${this.escapeAttr(entry.path)}">
        <i class="fa-solid fa-folder text-drac-yellow fa-fw shrink-0"></i>
        <span class="truncate min-w-0 flex-1">${this.escapeHTML(entry.name)}</span>
        <i class="fa-solid fa-chevron-right text-drac-comment shrink-0 text-xs"></i>
      </button>
    `).join("")
  }

  parentOf(path) {
    if (path === "/" || path === "") return "/"
    const parts = path.replace(/\/$/, "").split("/")
    parts.pop()
    return parts.join("/") || "/"
  }

  errorHTML(msg) {
    return `<p class="text-xs text-drac-red px-3 py-3">${this.escapeHTML(msg)}</p>`
  }

  escapeHTML(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
  }

  escapeAttr(str) {
    return String(str).replace(/"/g, "&quot;")
  }
}
