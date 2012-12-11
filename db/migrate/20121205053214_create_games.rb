class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :team_id
      t.string :opponent
      t.string :stubhub_id
      t.datetime :date
      t.integer :average_price
      t.integer :average_popularity

      t.timestamps
    end
  end
end
