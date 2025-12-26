import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    this.timeout = null
  }

  search() {
    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Wait 300ms after user stops typing before searching
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 600)
  }

  clear() {
    // Clear the input and search immediately
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    this.inputTarget.value = ""
    this.formTarget.requestSubmit()
  }
}

