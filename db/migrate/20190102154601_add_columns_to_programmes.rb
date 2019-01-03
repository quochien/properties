class AddColumnsToProgrammes < ActiveRecord::Migration[5.2]
  def change
    add_column :programmes, :source_id, :string
  end
end
