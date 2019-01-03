class CreateSites < ActiveRecord::Migration[5.2]
  def change
    create_table :sites do |t|
      t.string :site_name, null: false
      t.string :url, null: false
    end
  end
end
