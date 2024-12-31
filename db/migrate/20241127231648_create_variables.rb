class CreateVariables < ActiveRecord::Migration[7.2]
  def change
    create_table :variables do |t|
      t.string :key
      t.text :value
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :variables, :key
  end
end
