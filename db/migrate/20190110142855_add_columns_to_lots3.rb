class AddColumnsToLots3 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :size, :float
  end
end
