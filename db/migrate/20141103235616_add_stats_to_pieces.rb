class AddStatsToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :words, :integer
    add_column :pieces, :chars, :integer
    add_column :pieces, :chars_no_spaces, :integer
  end
end
