class RemoveAveragePopularityColumnFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :average_popularity
  end
end
