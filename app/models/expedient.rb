class Expedient < ApplicationRecord
  belongs_to :subject
  belongs_to :destination
  belongs_to :daily_agenda, optional: true

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
end
