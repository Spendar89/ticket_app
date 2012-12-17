class AddAveragePopularityToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :average_popularity, :integer
  end
end
