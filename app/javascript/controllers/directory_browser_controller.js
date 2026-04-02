import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "browser", "list", "currentPath", "upButton", "shortcuts"]
  static values = {
    current: String,
    noSubdirectoriesText: { type: String, default: "No subdirectories" },
    errorText: { type: String, default: "Could not read directory" }
  }

  // Toggle the browser panel open/closed
  toggle() {
    if (this.browserTarget.hidden) {
      this.browserTarget.hidden = false
      this._loadPath(this.inputTarget.value.trim() || "/")
    } else {
      this.browserTarget.hidden = true
    }
  }

  // Navigate into a directory (called from button data-action)
  navigate(event) {
    event.stopPropagation()
    this._loadPath(event.currentTarget.dataset.path)
  }

  // Write the current path into the text input and close the browser
  select(event) {
    event.stopPropagation()
    this.inputTarget.value = this.currentValue
    this.browserTarget.hidden = true
  }

  // Clear the path input
  clearInput() {
    this.inputTarget.value = ""
    this.inputTarget.focus()
  }

  _loadPath(path) {
    this.currentValue = path
    this.currentPathTarget.textContent = path

    // Update the "up" button target
    const parent = this._parentOf(path)
    this.upButtonTarget.dataset.path = parent
    this.upButtonTarget.disabled     = path === "/"

    fetch(`/scan_paths/browser?path=${encodeURIComponent(path)}`)
      .then(response => response.json())
      .then(data => {
        if (data.error) {
          this._renderError(data.error)
        } else {
          this._renderShortcuts(data.shortcuts || [])
          this._renderEntries(data.entries)
        }
      })
      .catch(() => {
        this._renderError(this.errorTextValue)
      })
  }

  _renderShortcuts(shortcuts) {
    if (!this.hasShortcutsTarget) return
    this.shortcutsTarget.replaceChildren(
      ...shortcuts.map(shortcut => {
        const btn = document.createElement("button")
        btn.type = "button"
        btn.className = "text-xs px-2 py-0.5 rounded border border-base-300 text-muted hover:border-base-content hover:text-base-content transition-colors cursor-pointer"
        btn.dataset.action = "click->directory-browser#navigate"
        btn.dataset.path = shortcut
        btn.textContent = shortcut
        return btn
      })
    )
  }

  _renderEntries(entries) {
    if (entries.length === 0) {
      const p = document.createElement("p")
      p.className = "text-xs text-muted px-3 py-3 italic"
      p.textContent = this.noSubdirectoriesTextValue
      this.listTarget.replaceChildren(p)
      return
    }

    this.listTarget.replaceChildren(
      ...entries.map(entry => {
        const btn = document.createElement("button")
        btn.type = "button"
        btn.className = "w-full flex items-center gap-2 px-3 py-2 text-left text-sm text-base-content hover:bg-base-200 transition-colors"
        btn.dataset.action = "click->directory-browser#navigate"
        btn.dataset.path = entry.path

        const folder = document.createElement("i")
        folder.className = "fa-solid fa-folder text-warning fa-fw shrink-0"

        const name = document.createElement("span")
        name.className = "truncate min-w-0 flex-1"
        name.textContent = entry.name

        const chevron = document.createElement("i")
        chevron.className = "fa-solid fa-chevron-right text-muted shrink-0 text-xs"

        btn.append(folder, name, chevron)
        return btn
      })
    )
  }

  _parentOf(path) {
    if (path === "/" || path === "") return "/"
    const parts = path.replace(/\/$/, "").split("/")
    parts.pop()
    return parts.join("/") || "/"
  }

  _renderError(msg) {
    const p = document.createElement("p")
    p.className = "text-xs text-error px-3 py-3"
    p.textContent = msg
    this.listTarget.replaceChildren(p)
  }
}
