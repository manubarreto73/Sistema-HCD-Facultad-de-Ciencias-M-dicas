class AddDailyAgendaToExpedients < ActiveRecord::Migration[8.0]
  def change
    add_reference :expedients, :daily_agenda, foreign_key: true
  end
end
