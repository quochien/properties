class AddUrlToProgrammes < ActiveRecord::Migration[5.2]
  def change
    add_column :programmes, :url, :string
  end
end
