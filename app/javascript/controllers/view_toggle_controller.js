import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["listView", "cardView", "listBtn", "cardBtn"]

  connect () {
    this.applyView()
  }

  listViewTargetConnected () {
    this.applyView()
  }

  cardViewTargetConnected () {
    this.applyView()
  }

  showList () {
    this.show("list")
  }

  showCard () {
    this.show("card")
  }

  show (view) {
    localStorage.setItem("games-view", view)
    this.applyView()
  }

  applyView () {
    const stored = localStorage.getItem("games-view")
    const view = stored === "list" || stored === "card" ? stored : "card"

    if (this.hasListViewTarget) {
      this.listViewTarget.classList.toggle("hidden", view !== "list")
    }

    if (this.hasCardViewTarget) {
      this.cardViewTarget.classList.toggle("hidden", view !== "card")
    }

    if (this.hasListBtnTarget) {
      this.listBtnTarget.classList.toggle("btn-active", view === "list")
    }

    if (this.hasCardBtnTarget) {
      this.cardBtnTarget.classList.toggle("btn-active", view === "card")
    }
  }
}
