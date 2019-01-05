class AddColumnsToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :notary_fee, :string
    add_column :lots, :security_deposit, :string
    add_column :lots, :lot_name, :string
    add_column :lots, :full_desc, :string
    add_column :lots, :city_text, :string
    add_column :lots, :expected_delivery, :string
    add_column :lots, :expected_actability, :string
    add_column :lots, :price_text, :string
  end
end
