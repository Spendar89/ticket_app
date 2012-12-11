class AddSectionStandardDeviationsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :section_standard_deviations, :text
  end
end
