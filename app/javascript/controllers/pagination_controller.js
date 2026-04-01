import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "sentinel"]
  static values = { url: String }

  sentinelTargetConnected () {
    this.observer = new IntersectionObserver(
      (entries) => { if (entries[0].isIntersecting) this.loadMore() },
      { rootMargin: "200px" }
    )
    this.observer.observe(this.sentinelTarget)
  }

  disconnect () {
    this.observer?.disconnect()
  }

  loadMore () {
    if (this.loading) return

    this.loading = true
    this.observer.disconnect()

    fetch(this.urlValue, { headers: { Accept: "text/html" } })
      .then((r) => r.text())
      .then((html) => {
        const template = document.createElement("template")
        template.innerHTML = html.trim()

        const items = template.content.querySelector("[data-items]")
        if (items) this.containerTarget.insertAdjacentHTML("beforeend", items.innerHTML)

        const next = template.content.querySelector("[data-pagination-next]")
        if (next) {
          this.urlValue = next.dataset.paginationNext
          this.sentinelTarget.remove()
          this.containerTarget.insertAdjacentHTML("afterend", next.outerHTML)
        } else {
          this.sentinelTarget.remove()
        }

        this.loading = false
      })
      .catch(() => { this.loading = false })
  }
}
