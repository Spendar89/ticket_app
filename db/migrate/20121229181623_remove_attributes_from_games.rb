class RemoveAttributesFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :stubhub_id
    remove_column :games, :latitude
    remove_column :games, :relative_price
    remove_column :games, :venue
  end
end
