class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.integer :node_id
      t.string :ch_index
      t.string :message
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :messages, :node_id
  end
end
