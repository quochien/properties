class AddLogoToSites < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :logo, :string
  end
end
