class AddColumnsToLots5 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :price_without_vat_exclude_furniture, :string
    add_column :lots, :loyer_ht, :string
    add_column :lots, :price_of_furniture_exclude_vat, :string
    add_column :lots, :total_price_exclude_vat, :string
  end
end
