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

  def treated?
    return false unless expedients.any?

    expedients.all? { |exp| exp.file_status == 'treated' }
  end

  def self.next_daily_agenda
    today_agendas = where(date: Date.today)
    exists = today_agendas.any?
    return create(date: Date.today) unless exists

    not_treated = today_agendas.find { |d| !d.treated? }
    not_treated || create(date: Date.today)
  end
end
