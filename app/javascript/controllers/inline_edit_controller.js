import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "textarea"]

  edit(event) {
    if (!this.formTarget.classList.contains("hidden")) return
    this.originalBody = this.displayTarget.dataset.originalBody || ""
    this.originalPageDate = this.displayTarget.dataset.originalPageDate || ""
    this.originalPlace = this.displayTarget.dataset.originalPlace || ""
    this.textareaTarget.value = this.originalBody
    this._resetMetaFields(this.originalPageDate, this.originalPlace)
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.textareaTarget.focus()
  }

  connect() {
    this.isSaving = false
    this.formTarget.addEventListener("turbo:submit-end", () => {
      this.isSaving = false
    })
  }

  save(event) {
    event.preventDefault()
    if (this.isSaving) return
    this.isSaving = true
    this.formTarget.requestSubmit()
  }

  cancel(event) {
    event.preventDefault()
    this.isSaving = false
    this.textareaTarget.value = this.originalBody
    this._resetMetaFields(this.originalPageDate, this.originalPlace)
    this.displayTarget.classList.remove("hidden")
    this.formTarget.classList.add("hidden")
  }

  clickOutside(event) {
    if (this.formTarget.classList.contains("hidden")) return
    if (this.element.contains(event.target)) return
    this.save(event)
  }

  _resetMetaFields(dateValue, placeValue) {
    const dateField = this.formTarget.querySelector("[name='page[page_date]']")
    const placeField = this.formTarget.querySelector("[name='page[place]']")
    if (dateField) dateField.value = dateValue
    if (placeField) placeField.value = placeValue
  }
}
