import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "button"]
  static values = { name: String, path: String }

  reveal() {
    const link = document.createElement("a")
    link.href = this.pathValue
    link.textContent = this.nameValue
    this.displayTarget.replaceWith(link)
    this.buttonTarget.remove()
  }
}
