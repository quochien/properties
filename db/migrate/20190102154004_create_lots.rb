class CreateLots < ActiveRecord::Migration[5.2]
  def change
    create_table :lots do |t|
      t.integer :site_id
      t.integer :programme_id
      t.string :lot_source_id
      t.string :programme_source_id
      t.string :terrasse_text
      t.string :parking_text
      t.string :images

      t.timestamps
    end
  end
end
