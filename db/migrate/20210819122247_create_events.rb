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

# class CreateDocs < ActiveRecord::Migration[6.1]
#   def change
#     create_table :docs do |t|
#         t.references :event, index: true, foreign_key: true
#         t.text :document_data
#     end
#   end
# end
