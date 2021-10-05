class ChangeColumnReciverToReceiver < ActiveRecord::Migration[6.1]
  def change
    rename_column :invites, :reciver_id, :receiver_id
  end
end
