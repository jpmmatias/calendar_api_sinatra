class CreateInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :invites do |t|
      t.integer :status, default: 0, null: false
      t.references :sender, references: :user, index: true, null: false,
                            foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :reciver, references: :user, index: true, null: false,
                             foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :event, references: :event, index: true, null: false,
                           foreign_key: { to_table: :events, on_delete: :cascade }
      t.timestamps
    end
  end
end
