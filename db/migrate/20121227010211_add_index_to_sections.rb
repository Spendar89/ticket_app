class AddIndexToSections < ActiveRecord::Migration
  def change
    add_index :sections, :name
  end
end
