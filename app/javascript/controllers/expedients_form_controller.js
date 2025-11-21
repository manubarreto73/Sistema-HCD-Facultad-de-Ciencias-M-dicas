import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "checkbox", "selectedList"]

  toggle(e) {
    const row = e.currentTarget
    const checkbox = row.querySelector("[data-expedients-form-target='checkbox']")
    const id = row.dataset.id
    const number = row.dataset.number

    // invertimos el estado del checkbox
    checkbox.checked = !checkbox.checked

    if (checkbox.checked) {
      row.classList.add("bg-indigo-100") // <-- fondo seleccionado
      this.addSelected(id, number)
    } else {
      row.classList.remove("bg-indigo-100") // <-- fondo seleccionado

      this.removeSelected(id)
    }
  }

  addSelected(id, number) {
    // evita duplicados
    if (this.element.querySelector(`#selected-${id}`)) return

    const div = document.createElement("div")
    div.id = `selected-${id}`
    div.classList = "expedient-breadcrumb"

    div.innerHTML = `
      ${number}
      <button
        type="button"
        class="cursor-pointer pl-1"
        data-id="${id}"
        data-number="${number}"
      >
        ✕
      </button>
    `

    // Evento para la X
    div.querySelector("button").addEventListener("click", this.removeFromTag.bind(this))

    this.selectedListTarget.appendChild(div)
  }

  removeFromTag(e) {
    const id = e.currentTarget.dataset.id

    // sacar el div de la lista
    const tag = this.element.querySelector(`#selected-${id}`)
    if (tag) tag.remove()

    // sacar el check del checkbox correspondiente
    const checkbox = this.checkboxTargets.find(cb => cb.value === id)
    if (checkbox) checkbox.checked = false

    const row = this.itemTargets.find(item => item.dataset.id === id)
    if (row) row.classList.remove("bg-indigo-100")
  }

  removeSelected(id) {
    const tag = this.element.querySelector(`#selected-${id}`)
    if (tag) tag.remove()
  }
}
