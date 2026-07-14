import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "textarea", "counter", "formActions"]

  edit(event) {
    if (!this.formTarget.classList.contains("hidden")) return
    this.originalBody = this.displayTarget.dataset.originalBody || ""
    this.originalPageDate = this.displayTarget.dataset.originalPageDate || ""
    this.originalPlace = this.displayTarget.dataset.originalPlace || ""
    this.textareaTarget.value = this.originalBody
    this._resetMetaFields(this.originalPageDate, this.originalPlace)
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.formActionsTarget.classList.remove("hidden")
    this.textareaTarget.focus()
    this._refreshCounter()
  }

  connect() {
    this.isSaving = false

    if (!this.formTarget.classList.contains("hidden")) {
      this.formActionsTarget.classList.remove("hidden")
      this.displayTarget.classList.add("hidden")
    }

    this._pageLinkHandler = (event) => {
      const link = event.target.closest(".page-link")
      if (!link) return
      if (this.formTarget.classList.contains("hidden")) return

      event.preventDefault()
      event.stopPropagation()

      const href = link.href
      if (this.isSaving) return
      this.isSaving = true

      const afterSave = (saveEvent) => {
        this.formTarget.removeEventListener("turbo:submit-end", afterSave)
        this.isSaving = false
        if (saveEvent.detail.success) {
          window.location.href = href
        }
      }

      this.formTarget.addEventListener("turbo:submit-end", afterSave)
      this.formTarget.requestSubmit()
    }

    document.addEventListener("click", this._pageLinkHandler)
  }

  disconnect() {
    document.removeEventListener("click", this._pageLinkHandler)
  }

  save(event) {
    event.preventDefault()
    if (this.isSaving) return
    this.isSaving = true
    this.formActionsTarget.classList.add("hidden")
    this.formTarget.addEventListener("turbo:submit-end", (event) => {
      this.isSaving = false
      if (!event.detail.success) {
        this.formActionsTarget.classList.remove("hidden")
      }
    }, { once: true })
    this.formTarget.requestSubmit()
  }

  cancel(event) {
    event.preventDefault()
    event.stopPropagation()
    this.isSaving = false
    this.textareaTarget.value = this.displayTarget.dataset.originalBody || ""
    this._resetMetaFields(this.displayTarget.dataset.originalPageDate || "", this.displayTarget.dataset.originalPlace || "")
    this.displayTarget.classList.remove("hidden")
    this.formTarget.classList.add("hidden")
    this.formActionsTarget.classList.add("hidden")
    this._refreshCounter()
  }

  clickOutside(event) {
    if (this.formTarget.classList.contains("hidden")) return
    if (this.element.contains(event.target)) return
    this.save(event)
  }

  updateCounter(event) {
    this._setCounterText(event.target.value.length)
  }

  _resetMetaFields(dateValue, placeValue) {
    const dateField = this.formTarget.querySelector("[name='page[page_date]']")
    const placeField = this.formTarget.querySelector("[name='page[place]']")
    if (dateField) dateField.value = dateValue
    if (placeField) placeField.value = placeValue
  }

  _refreshCounter() {
    this._setCounterText(this.textareaTarget.value.length)
  }

  _setCounterText(len) {
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${len} / 1500`
    }
  }
}
