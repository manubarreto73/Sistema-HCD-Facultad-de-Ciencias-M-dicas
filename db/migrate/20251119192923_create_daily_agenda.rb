class CreateDailyAgenda < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_agendas do |t|
      t.date :date, default: Date.today, null: false

      t.timestamps
    end 
  end
end
