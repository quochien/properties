class AddColumnsToLots1 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :ville, :string
    add_column :lots, :postal_code, :string
    add_column :lots, :department, :string
    add_column :lots, :price, :integer
    add_column :lots, :disponibilite, :string
    add_column :lots, :lot_type, :string
    add_column :lots, :superficie, :string
    add_column :lots, :etage, :integer
    add_column :lots, :zone, :string
    add_column :lots, :fiscalite, :string
  end
end
