class RemoveColumnsFromGames < ActiveRecord::Migration
 def change
   remove_column :games, :home
   remove_column :games, :popularity_multiplier
   remove_column :teams, :home_average_price
   remove_column :teams, :away_average_price
   remove_column :teams, :pop_std_dev
   remove_column :teams, :average_popularity
   remove_column :teams, :section_averages
   remove_column :teams, :home_standard_deviation
   remove_column :teams, :home_price_standard_deviation
   remove_column :teams, :section_standard_deviation
   remove_column :teams, :seat_views
   remove_column :teams, :arena_image
   remove_column :teams, :best_game_id
 end
end
