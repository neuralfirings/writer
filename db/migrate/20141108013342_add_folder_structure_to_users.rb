class AddFolderStructureToUsers < ActiveRecord::Migration
  def change
    add_column :users, :folderstructure, :text
  end
end
