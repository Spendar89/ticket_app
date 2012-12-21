class ChangeRatingForPlayers < ActiveRecord::Migration
  def change
    change_column :stars, :rating, :decimal
  end
end
