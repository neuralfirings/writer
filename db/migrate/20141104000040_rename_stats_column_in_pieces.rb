class RenameStatsColumnInPieces < ActiveRecord::Migration
  def self.up
    rename_column :pieces, :chars_no_spaces, :chars_no_space
  end

  def self.down
    rename_column :pieces, :chars_no_space, :chars_no_spaces
  end
end
