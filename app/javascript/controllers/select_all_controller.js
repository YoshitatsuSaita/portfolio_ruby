import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "checkbox"]

  connect() {
    this.update()
  }

  toggle() {
    const checked = this.toggleTarget.checked
    this.checkboxTargets.forEach(cb => cb.checked = checked)
  }

  update() {
    this.toggleTarget.checked = this.checkboxTargets.every(cb => cb.checked)
  }
}
