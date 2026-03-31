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
    const nextPage = this.pageValue + 1

    const url = new URL(window.location.href)
    url.searchParams.set("page", nextPage)
    url.searchParams.set("append", "true")

    fetch(url, { headers: { "Accept": "text/html" } })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.text()
      })
      .then(html => {
        this.pageValue = nextPage

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
        } else {
          this.observer.unobserve(this.sentinelTarget)
          this.observer.observe(this.sentinelTarget)
        }
      })
      .catch((error) => {
        console.error("Load more failed:", error)
        this.loading = false
      })
  }
}
