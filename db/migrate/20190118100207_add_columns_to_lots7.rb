class AddColumnsToLots7 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :logements, :string
    add_column :lots, :pleine_propriete, :string
    add_column :lots, :usufruitier, :string
    add_column :lots, :duree_usufruit_temporaire, :string
  end
end
