import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "dialogMessage", "selectButton", "actionBar", "secondaryActions", "selectedCount"]

  connect() {
    this.selectionMode = false
    this.pendingForm = null
    this.pendingIds = []
  }

  toggle() {
    this.selectionMode = !this.selectionMode
    this.element.classList.toggle("selection-active", this.selectionMode)
    this.secondaryActionsTarget.classList.toggle("hidden", !this.selectionMode)
    this.selectButtonTarget.textContent = this.selectionMode ? "Cancel" : "Delete Multi"
    this.selectButtonTarget.classList.toggle("danger", !this.selectionMode)
    this.selectButtonTarget.classList.toggle("secondary", this.selectionMode)
    if (!this.selectionMode) this._clearSelection()
  }

  toggleSelect(event) {
    if (!this.selectionMode) return
    event.preventDefault()
    const li = event.currentTarget.closest("li")
    if (!li) return
    li.classList.toggle("selected")
    this._updateCount()
  }

  selectSection(event) {
    if (!this.selectionMode) return
    const card = event.currentTarget.closest('.document-list-card')
    if (!card) return
    const items = card.querySelectorAll('li')
    const allSelected = Array.from(items).every(li => li.classList.contains('selected'))
    items.forEach(li => li.classList.toggle('selected', !allSelected))
    this._updateCount()
  }

  confirmSingleDelete(event) {
    event.preventDefault()
    const button = event.currentTarget
    const name = button.dataset.documentName
    this.pendingForm = button.closest("form")
    this.pendingIds = []
    this.dialogMessageTarget.textContent = `Delete "${name}"?`
    this.dialogTarget.showModal()
  }

  confirmBulkDestroy() {
    const selected = this.element.querySelectorAll("li.selected")
    if (selected.length === 0) return
    this.pendingIds = Array.from(selected).map(li => li.dataset.documentId)
    this.pendingForm = null
    this.dialogMessageTarget.textContent = `Delete ${selected.length} selected document${selected.length > 1 ? "s" : ""}?`
    this.dialogTarget.showModal()
  }

  confirm() {
    if (this.pendingForm) {
      this.dialogTarget.close()
      this.pendingForm.requestSubmit()
    } else if (this.pendingIds.length > 0) {
      this.dialogTarget.close()
      this._submitBulkDestroy()
    }
  }

  closeDialog() {
    this.dialogTarget.close()
  }

  cancel() {
    this.selectionMode = false
    this.element.classList.remove("selection-active")
    this.secondaryActionsTarget.classList.add("hidden")
    this.selectButtonTarget.textContent = "Delete Multi"
    this.selectButtonTarget.classList.add("danger")
    this.selectButtonTarget.classList.remove("secondary")
    this._clearSelection()
  }

  selectAll(event) {
    const checked = event.currentTarget.checked
    this.element.querySelectorAll("li").forEach(li => {
      li.classList.toggle("selected", checked)
    })
    this._updateCount()
  }

  _clearSelection() {
    this.element.querySelectorAll("li.selected").forEach(li => li.classList.remove("selected"))
    this._updateCount()
  }

  _updateCount() {
    const count = this.element.querySelectorAll("li.selected").length
    this.selectedCountTarget.textContent = count
  }

  _submitBulkDestroy() {
    const form = document.createElement("form")
    form.method = "post"
    form.action = "/documents/bulk_destroy"
    form.dataset.turbo = "true"

    const csrfToken = document.querySelector("[name='csrf-token']")?.content
    if (csrfToken) {
      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
    }

    this.pendingIds.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "document_ids[]"
      input.value = id
      form.appendChild(input)
    })

    document.body.appendChild(form)
    form.requestSubmit()
  }
}
