class AddSeatViewsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :seat_views, :text
  end
end
