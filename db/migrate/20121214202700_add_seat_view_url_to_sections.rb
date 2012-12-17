class AddSeatViewUrlToSections < ActiveRecord::Migration
  def change
    add_column :sections, :seat_view_url, :string
  end
end
