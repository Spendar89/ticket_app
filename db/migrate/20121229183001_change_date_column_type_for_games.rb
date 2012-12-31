class ChangeDateColumnTypeForGames < ActiveRecord::Migration
  def change
    remove_column :games, :date
    add_column :games, :date, :date
  end
end
