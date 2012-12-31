class RemovePopularityColumnsFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :popularity
    remove_column :games, :relative_popularity
    add_column :games, :game_rating, :integer
  end
end
