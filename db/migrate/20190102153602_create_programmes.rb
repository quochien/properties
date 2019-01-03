class CreateProgrammes < ActiveRecord::Migration[5.2]
  def change
    create_table :programmes do |t|
      t.string :programme_name
      t.string :images

      t.timestamps
    end
  end
end
