class AddPopStdDevToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :pop_std_dev, :integer
  end
end
