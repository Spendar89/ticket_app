class ChangeDatatypeForRowInTeams < ActiveRecord::Migration
  def change
    change_column :teams, :pop_std_dev, :decimal
    change_column :teams, :average_popularity, :decimal
  end
end
