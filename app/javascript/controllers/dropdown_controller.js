import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "icon"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.iconTarget.classList.toggle("rotate-180")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      this.iconTarget.classList.remove("rotate-180")
    }
  }

  connect() {
    document.addEventListener("click", this.hide.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.hide.bind(this))
  }
}
