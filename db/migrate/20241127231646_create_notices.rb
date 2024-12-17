class CreateNotices < ActiveRecord::Migration[7.2]
  def change
    create_table :notices do |t|
      t.integer :number
      t.string :message
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end

# @notice 1 this is a test
# @notice 2 this is another test
# @notice 3 this is a 3rd test