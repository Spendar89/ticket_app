class AddAttributeToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :home_average_price, :integer
    add_column :teams, :away_average_price, :integer
    add_column :teams, :home_average_popularity, :integer
    add_column :teams, :home_standard_deviation, :integer
    add_column :teams, :home_price_standard_deviation, :integer
    add_column :teams, :away_price_standard_deviation, :integer
  end
end
