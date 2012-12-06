class ChangeDateFormatInGames < ActiveRecord::Migration
  def change
    change_column :games, :date, :string
  end
end
