class AddArenaImageToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :arena_image, :string
  end
end
