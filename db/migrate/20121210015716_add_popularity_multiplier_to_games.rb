class AddPopularityMultiplierToGames < ActiveRecord::Migration
  def change
    remove_column :games, :popularity_multiplier
    add_column :games, :popularity_multiplier, :decimal
  end
end
