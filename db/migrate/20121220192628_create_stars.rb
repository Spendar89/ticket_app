class CreateStars < ActiveRecord::Migration
  def change
    create_table :stars do |t|
      t.string :name
      t.integer :rating
      t.integer :team_id

      t.timestamps
    end
  end
end
