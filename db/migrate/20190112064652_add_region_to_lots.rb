class AddRegionToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :region, :string
  end
end
