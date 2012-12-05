class AddAttributesToGames < ActiveRecord::Migration
  def change
    add_column :games, :home, :boolean
    add_column :games, :venue, :string
    add_column :games, :latitude, :integer
    add_column :games, :longitude, :integer
    add_column :games, :popularity, :integer
  end
end
