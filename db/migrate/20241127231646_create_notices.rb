class CreateNotices < ActiveRecord::Migration[7.2]
  def change
    create_table :notices do |t|
      t.string :ch_index
      t.integer :number
      t.string :message
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
