class ChangeDataTypeForRowInTickets < ActiveRecord::Migration
  def change
    change_column :tickets, :row, :string
  end
end
