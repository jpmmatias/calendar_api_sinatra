class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :name
      t.string :local
      t.text :description
      t.string :owner
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
