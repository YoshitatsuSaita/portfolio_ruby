import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open() {
    this.dialogTarget.style.display = "block"
    document.body.classList.add("modal-open")
    this.backdrop = document.createElement("div")
    this.backdrop.className = "modal-backdrop fade"
    document.body.appendChild(this.backdrop)
    this.dialogTarget.addEventListener("click", this.handleBackdropClick)
    requestAnimationFrame(() => {
      this.dialogTarget.classList.add("in")
      this.backdrop.classList.add("in")
    })
  }

  close() {
    this.dialogTarget.removeEventListener("click", this.handleBackdropClick)
    this.dialogTarget.classList.remove("in")
    this.dialogTarget.style.display = "none"
    document.body.classList.remove("modal-open")
    if (this.backdrop) {
      this.backdrop.remove()
      this.backdrop = null
    }
  }

  handleBackdropClick = (event) => {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}
