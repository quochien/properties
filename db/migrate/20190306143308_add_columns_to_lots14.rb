class AddColumnsToLots14 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :enabled, :boolean, default: true
  end
end
