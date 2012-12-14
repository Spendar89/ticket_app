class Ticket < ActiveRecord::Base
  attr_accessible :game_id, :price, :quantity, :row, :section_id, :stubhub_id, :url
  belongs_to :game
  belongs_to :section, :inverse_of => :tickets
  validates :stubhub_id, :uniqueness => true

  def seat_value
      unless self.section.nil? || self.section[:average_price].nil?
        row = self.row
        section = self.section
        price = self.price
        (((price.to_i + row.to_i) - section[:average_price].to_f)/(section[:std_dev]).to_f)
      end
  end

  def destroy_if_outlier
    self.destroy if self.seat_value > 3.5
  end

  def converted_letter_row(row)
    letters = ('A'..'Z').to_a
    converted_letters = {}
    letters.each_with_index do |letter, i|
      converted_letters.merge!(letter => i +1)
    end
    converted_letters[row].to_i
  end
end