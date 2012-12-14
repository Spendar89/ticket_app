class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :team_id
      t.integer :average_price
      t.integer :std_dev

      t.timestamps
    end
  end
end
