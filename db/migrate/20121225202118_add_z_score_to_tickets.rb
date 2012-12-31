class AddZScoreToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :z_score, :decimal
  end
end
