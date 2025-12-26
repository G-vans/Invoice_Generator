import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["itemsContainer", "productSearch", "productList", "subtotal", "taxAmount", "grandTotal"]
  static values = { currency: String }

  connect() {
    this.currencySymbol = this.currencyValue || "$"
    this.setupEventListeners()
    this.initializeExistingItems()
    this.updateTotals()
  }

  initializeExistingItems() {
    // Calculate totals for existing items
    document.querySelectorAll(".invoice-item-row").forEach(row => {
      this.updateItemTotal(row)
    })
  }

  setupEventListeners() {
    // Product search
    if (this.hasProductSearchTarget) {
      this.productSearchTarget.addEventListener("input", (e) => this.filterProducts(e.target.value))
    }

    // Product item clicks
    document.querySelectorAll(".product-item").forEach(button => {
      button.addEventListener("click", (e) => this.addProductFromCatalog(e))
    })

    // Add custom item button
    const addCustomBtn = document.getElementById("add-custom-item")
    if (addCustomBtn) {
      addCustomBtn.addEventListener("click", () => this.addCustomItem())
    }

    // Delegate events for dynamic items
    if (this.hasItemsContainerTarget) {
      this.itemsContainerTarget.addEventListener("input", (e) => {
        if (e.target.classList.contains("item-quantity") || e.target.classList.contains("item-price")) {
          this.updateItemTotal(e.target.closest(".invoice-item-row"))
          this.updateTotals()
        }
      })

    // Tax rate change
    const taxRateField = document.querySelector("#invoice_tax_rate")
    if (taxRateField) {
      taxRateField.addEventListener("input", () => this.updateTotals())
    }

      this.itemsContainerTarget.addEventListener("click", (e) => {
        if (e.target.classList.contains("remove-item")) {
          this.removeItem(e.target.closest(".invoice-item-row"))
        }
      })
    }
  }

  filterProducts(query) {
    const items = document.querySelectorAll(".product-item")
    const lowerQuery = query.toLowerCase()
    
    items.forEach(item => {
      const name = item.dataset.productName.toLowerCase()
      const description = item.dataset.productDescription?.toLowerCase() || ""
      if (name.includes(lowerQuery) || description.includes(lowerQuery)) {
        item.style.display = "block"
      } else {
        item.style.display = "none"
      }
    })
  }

  addProductFromCatalog(event) {
    const button = event.currentTarget
    const productId = button.dataset.productId
    const productName = button.dataset.productName
    const productDescription = button.dataset.productDescription || productName

    this.addItemRow(productId, productDescription)
  }

  addCustomItem() {
    this.addItemRow(null, "")
  }

  addItemRow(productId, description) {
    const container = document.getElementById("invoice-items")
    const timestamp = Date.now()
    
    const row = document.createElement("div")
    row.className = "invoice-item-row border-b border-gray-200 pb-4 mb-4"
    row.innerHTML = `
      <div class="grid grid-cols-12 gap-4">
        <div class="col-span-5">
          <input type="hidden" name="invoice[invoice_items_attributes][${timestamp}][product_id]" value="${productId || ""}" class="product-id-field">
          <input type="text" name="invoice[invoice_items_attributes][${timestamp}][description]" value="${description}" placeholder="Description" required class="block w-full rounded-md border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500 sm:text-sm">
        </div>
        <div class="col-span-2">
          <input type="number" name="invoice[invoice_items_attributes][${timestamp}][quantity]" value="1" step="0.01" min="0.01" required class="item-quantity block w-full rounded-md border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500 sm:text-sm">
        </div>
        <div class="col-span-3">
          <input type="number" name="invoice[invoice_items_attributes][${timestamp}][unit_price]" value="0" step="0.01" min="0" required placeholder="Price" class="item-price block w-full rounded-md border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500 sm:text-sm">
        </div>
                    <div class="col-span-1">
                      <span class="item-total block w-full text-sm font-medium text-gray-900 text-right">${this.currencySymbol} 0.00</span>
                    </div>
        <div class="col-span-1">
          <button type="button" class="remove-item text-gray-600 hover:text-gray-900 text-sm font-medium">Remove</button>
        </div>
      </div>
    `
    
    container.appendChild(row)
    this.updateItemTotal(row)
    this.updateTotals()
  }

  removeItem(row) {
    // For edit form, mark as destroy instead of removing
    const destroyField = row.querySelector(".destroy-field")
    if (destroyField) {
      destroyField.value = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
    this.updateTotals()
  }

  updateItemTotal(row) {
    const quantity = parseFloat(row.querySelector(".item-quantity")?.value || 0)
    const price = parseFloat(row.querySelector(".item-price")?.value || 0)
    const total = (quantity * price).toFixed(2)
    row.querySelector(".item-total").textContent = `${this.currencySymbol} ${total}`
  }

  updateTotals() {
    const rows = document.querySelectorAll(".invoice-item-row")
    let subtotal = 0

    rows.forEach(row => {
      const quantity = parseFloat(row.querySelector(".item-quantity")?.value || 0)
      const price = parseFloat(row.querySelector(".item-price")?.value || 0)
      subtotal += quantity * price
    })

    const taxRate = parseFloat(document.querySelector("#invoice_tax_rate")?.value || 0)
    const taxAmount = subtotal * (taxRate / 100)
    const grandTotal = subtotal + taxAmount

    const subtotalEl = document.getElementById("subtotal")
    const taxAmountEl = document.getElementById("tax-amount")
    const grandTotalEl = document.getElementById("grand-total")

    if (subtotalEl) subtotalEl.textContent = `${this.currencySymbol} ${subtotal.toFixed(2)}`
    if (taxAmountEl) taxAmountEl.textContent = `${this.currencySymbol} ${taxAmount.toFixed(2)}`
    if (grandTotalEl) grandTotalEl.textContent = `${this.currencySymbol} ${grandTotal.toFixed(2)}`
  }
}

