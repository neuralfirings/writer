class RenameUserId < ActiveRecord::Migration
  def self.up
    rename_column :logs, :user_id_id, :user_id
    rename_column :pieces, :user_id_id, :user_id
  end

  def self.down
    rename_column :logs, :user_id, :user_id_id
    rename_column :pieces, :user_id, :user_id_id
  end
end