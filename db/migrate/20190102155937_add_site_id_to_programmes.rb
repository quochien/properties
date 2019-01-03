class AddSiteIdToProgrammes < ActiveRecord::Migration[5.2]
  def change
    add_column :programmes, :site_id, :integer
  end
end
