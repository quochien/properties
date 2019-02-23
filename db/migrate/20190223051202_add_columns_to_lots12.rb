class AddColumnsToLots12 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :price_foncier, :string
  end
end
