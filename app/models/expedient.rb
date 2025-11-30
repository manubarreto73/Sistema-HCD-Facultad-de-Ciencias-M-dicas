class Expedient < ApplicationRecord
  belongs_to :subject, optional: true
  belongs_to :destination, optional: true
  belongs_to :daily_agenda, optional: true

  validates :file_number, uniqueness: { message: 'El número de expediente ya existe' }
  validates :file_number, presence: { message: 'El número de expediente no puede estar vacío' } 
  validates :file_number, length: { minimum: 19, message: 'El número de expediente es corto' }
  validates :responsible, length: { maximum: 50, message: 'El nombre del responsable es muy largo (máximo 30 carácteres)' }
  validates :opinion, length: { maximum: 200, message: 'El dictámen es muy largo (máximo 200 caracteres)' }
  validates :detail, length: { maximum: 200, message: 'El detalle es muy largo (máximo 200 carácteres)' }

  enum :file_status, {
    no_treated: 0,
    treated: 1,
    deleted: 2
  }

  scope :treated, -> { where(file_status: 'treated') }
  scope :no_treated, -> { where(file_status: 'no_treated') }
  scope :for_daily_agenda, lambda {
    where(file_status: 'no_treated',
          destination: Destination.find_by(name: 'Honorable Consejo Directivo'),
          daily_agenda_id: nil)
  }

  # Metodos para mejorar la info de las vistas

  def status
    case file_status
    when 'no_treated'
      'No tratado'
    when 'treated'
      'Tratado'
    else
      'Eliminado'
    end
  end

  def dependency
    return '' unless file_number

    file_number.split('-')[0]
  end

  def file_digits
    return '' unless file_number

    file_number.split('-')[1].split('/')[0]
  end

  def file_year
    return '' unless file_number

    file_number.split('-')[1].split('/')[1]
  end

  def correspondence
    return '' unless file_number

    file_number.split('-')[2]
  end

  def logic_delete
    deleted!
    update(subject: nil, destination: nil, daily_agenda: nil, file_number: "#{file_number}* [DELETED]")
  end
end
