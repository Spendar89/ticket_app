class AddSectionAveragesToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :section_averages, :text
  end
end
