class AddColumnsToLots8 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :price_without_construction, :string
    add_column :lots, :additional_price_construction, :string
    add_column :lots, :parking_price, :string
    add_column :lots, :cellar_price, :string
    add_column :lots, :subsidy, :string
  end
end
