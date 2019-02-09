class AddColumnsToLots9 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :address, :string
    add_column :lots, :prix_ht, :string
    add_column :lots, :loyer_pinel, :string
    add_column :lots, :prix_ht_mobilier, :string
    add_column :lots, :loyer, :string
    add_column :lots, :exposition, :string
    add_column :lots, :vat_rate, :string
    add_column :lots, :jardin, :string
    add_column :lots, :balcon, :string
    add_column :lots, :depot_de_garantie, :string
    add_column :lots, :frais_de_notaire, :string
    add_column :lots, :pls, :string
  end
end
