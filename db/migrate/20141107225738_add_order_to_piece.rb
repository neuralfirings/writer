class AddOrderToPiece < ActiveRecord::Migration
  def change
    add_column :pieces, :order, :integer
  end
end
