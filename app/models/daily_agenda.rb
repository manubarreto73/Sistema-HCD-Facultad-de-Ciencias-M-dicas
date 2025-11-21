class DailyAgenda < ApplicationRecord
  has_many :expedients, dependent: :nullify

  def solve
    expedients.update_all(file_status: 'treated')
  end

  def undo_solve
    expedients.update_all(file_status: 'no_treated')
  end

  def date_name
    "#{I18n.l(date, format: '%a')} #{date.day}"
  end
end
