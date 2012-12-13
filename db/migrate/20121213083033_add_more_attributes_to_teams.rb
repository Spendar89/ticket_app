class AddMoreAttributesToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :division, :string
    add_column :teams, :last_5, :string
  end
end
