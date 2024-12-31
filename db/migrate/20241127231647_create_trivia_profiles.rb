class CreateTriviaProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :trivia_profiles do |t|
      t.integer :node_id
      t.integer :points, default: 0
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :trivia_profiles, :node_id
  end
end
