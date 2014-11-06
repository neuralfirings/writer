class AddUserIdToPieces < ActiveRecord::Migration
  def change
    add_reference :pieces, :user_id, index: true
  end
end
