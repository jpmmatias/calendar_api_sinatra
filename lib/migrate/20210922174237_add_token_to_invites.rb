class AddTokenToInvites < ActiveRecord::Migration[6.1]
  def change
    add_column :invites, :token, :string 
    add_index :invites, :token, unique: true
  end
end
