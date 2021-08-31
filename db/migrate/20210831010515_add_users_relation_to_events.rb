class AddUsersRelationToEvents < ActiveRecord::Migration[6.1]
  def change
    remove_column :events, :owner, :string
    add_reference :events, :owner, references: :user, index: true
    add_foreign_key :events, :users, column: :owner_id
  end
end
