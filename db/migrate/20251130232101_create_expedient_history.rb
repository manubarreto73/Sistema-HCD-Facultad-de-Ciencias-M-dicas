class CreateExpedientHistory < ActiveRecord::Migration[8.0]
  def change
    create_table :expedient_histories do |t|
      t.references :expedient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :action
      t.string :description
      t.timestamps
    end
  end
end
