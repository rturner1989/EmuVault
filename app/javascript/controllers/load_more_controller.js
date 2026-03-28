import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["listContainer", "cardContainer", "sentinel"]
  static values = { page: Number, totalPages: Number }

  connect () {
    this.loading = false

    if (!this.hasSentinelTarget) return
    if (this.pageValue >= this.totalPagesValue) return

    this.observer = new IntersectionObserver(
      (entries) => { if (entries[0].isIntersecting) this.loadMore() },
      { rootMargin: "200px" }
    )
    this.observer.observe(this.sentinelTarget)
  }

  disconnect () {
    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
    }
  }

  loadMore () {
    if (this.loading) return
    if (this.pageValue >= this.totalPagesValue) return

    this.loading = true
    this.pageValue++

    const url = new URL(window.location.href)
    url.searchParams.set("page", this.pageValue)
    url.searchParams.set("append", "true")

    fetch(url, { headers: { "Accept": "text/html" } })
      .then(response => response.text())
      .then(html => {
        const template = document.createElement("template")
        template.innerHTML = html.trim()
        const fragment = template.content

        const listItems = fragment.querySelector("[data-load-more-list]")
        const cardItems = fragment.querySelector("[data-load-more-cards]")

        if (listItems && this.hasListContainerTarget) {
          this.listContainerTarget.insertAdjacentHTML("beforeend", listItems.innerHTML)
        }

        if (cardItems && this.hasCardContainerTarget) {
          this.cardContainerTarget.insertAdjacentHTML("beforeend", cardItems.innerHTML)
        }

        this.loading = false

        if (this.pageValue >= this.totalPagesValue) {
          this.observer.disconnect()
          this.sentinelTarget.remove()
        }
      })
  }
}
