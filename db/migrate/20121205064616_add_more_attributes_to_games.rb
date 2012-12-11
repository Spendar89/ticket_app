class AddMoreAttributesToGames < ActiveRecord::Migration
  def change
    add_column :games, :relative_popularity, :integer
    add_column :games, :relative_price, :integer
  end
end
