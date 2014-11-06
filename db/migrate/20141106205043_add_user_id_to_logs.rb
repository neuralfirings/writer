class AddUserIdToLogs < ActiveRecord::Migration
  def change
    add_reference :logs, :user_id, index: true
  end
end
