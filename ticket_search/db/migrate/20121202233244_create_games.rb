class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.datetime :date
      t.string :opponent
      t.integer :team_id
      t.integer :event_id

      t.timestamps
    end
  end
end
