class AddColumnsToLots2 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :reference, :string
  end
end
