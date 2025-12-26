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

    // Wait 600ms after user stops typing before searching
    this.timeout = setTimeout(() => {
      // Use Turbo to submit the form, which will update the frame
      this.formTarget.requestSubmit()
    }, 600)
  }
}

