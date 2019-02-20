class AddColumnsToLots10 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :offre_speciale, :string
  end
end
