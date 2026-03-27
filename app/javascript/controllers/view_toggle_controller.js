import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["listView", "cardView", "listBtn", "cardBtn"]

  connect () {
    const saved = localStorage.getItem("games-view") || "card"
    this.show(saved)
  }

  showList () {
    this.show("list")
  }

  showCard () {
    this.show("card")
  }

  show (view) {
    localStorage.setItem("games-view", view)

    this.listViewTarget.classList.toggle("hidden", view !== "list")
    this.cardViewTarget.classList.toggle("hidden", view !== "card")

    this.listBtnTarget.classList.toggle("btn-active", view === "list")
    this.cardBtnTarget.classList.toggle("btn-active", view === "card")
  }
}
