class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :title
      t.text :body
      t.integer :words
      t.integer :chars
      t.integer :chars_no_space
      t.references :piece, index: true

      t.timestamps
    end
  end
end
