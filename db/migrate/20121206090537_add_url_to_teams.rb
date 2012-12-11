class AddUrlToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :url, :string
  end
end
