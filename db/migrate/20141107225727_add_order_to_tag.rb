class AddOrderToTag < ActiveRecord::Migration
  def change
    add_column :tags, :order, :integer
  end
end
