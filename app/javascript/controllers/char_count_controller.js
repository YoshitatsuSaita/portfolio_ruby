import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display"]

  connect() {
    this.count()
  }

  count() {
    const len = this.inputTarget.value.length
    const max = 30
    this.displayTarget.textContent = `${len} / ${max}文字`

    if (len < 5 || len > max) {
      this.displayTarget.classList.add("text-danger")
    } else {
      this.displayTarget.classList.remove("text-danger")
    }
  }
}
