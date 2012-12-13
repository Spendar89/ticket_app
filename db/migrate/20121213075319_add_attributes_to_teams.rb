class AddAttributesToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :conference, :string
    add_column :teams, :record, :string
    add_column :teams, :venue_name, :string
    add_column :teams, :venue_address, :string
  end
end
