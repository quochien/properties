class AddColumnsToLots6 < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :gestionnaire, :string
    add_column :lots, :dureedubail, :string
  end
end
