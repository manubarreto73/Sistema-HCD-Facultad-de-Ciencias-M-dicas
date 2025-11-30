import { Controller } from "@hotwired/stimulus"

// Controlador que oculta el mensaje de error después de unos segundos
export default class extends Controller {
  static values = { 
    row: String
  }

  connect() {
    
    const elem = document.getElementById(this.rowValue).querySelectorAll('td')
    setTimeout(() => {
    elem.forEach(cell => {
      cell.classList.remove('bg-slate-400')
    })
    }, 1500)
  }
}