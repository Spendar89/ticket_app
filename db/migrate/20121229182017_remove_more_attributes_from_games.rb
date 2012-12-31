class RemoveMoreAttributesFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :longitude
  end
end
