class AddColumnsToLots11 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :price_ttc, :string
  end
end
