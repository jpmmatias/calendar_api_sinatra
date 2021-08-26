class CreateDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :documents do |t|
      t.references :event, index: true, foreign_key: true
      t.string :file_path, null:false

      t.timestamps
    end
  end
end
