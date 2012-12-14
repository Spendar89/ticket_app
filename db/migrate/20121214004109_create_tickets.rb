class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :game_id
      t.string :url
      t.integer :stubhub_id
      t.integer :price
      t.integer :row
      t.integer :quantity
      t.integer :section_id

      t.timestamps
    end
  end
end
