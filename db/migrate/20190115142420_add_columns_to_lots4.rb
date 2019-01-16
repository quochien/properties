class AddColumnsToLots4 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :market_rental, :string
    add_column :lots, :rentabilite, :string
    add_column :lots, :pinel_rental, :string
    add_column :lots, :pinel_rentabilite, :string
  end
end
