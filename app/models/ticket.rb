class Ticket < ActiveRecord::Base
  attr_accessible :game_id, :price, :quantity, :row, :section_id, :stubhub_id, :url
  belongs_to :game
  belongs_to :section, :inverse_of => :tickets
  validates :stubhub_id, :uniqueness => true, :numericality => true, :presence => true
  validates :url, :section_id, :presence => true

  def z_score
    if !self.price.nil? && !self.section[:average_price].nil? && self.section[:std_dev] > 0
      row = converted_row(self[:row]) * 2
      section = self.section
      price_difference = (self.price.to_f + row) - section[:average_price]
      section_std_dev = section[:std_dev].to_f
      (price_difference/section_std_dev).to_f
    end
  end
  
  def seat_value
     return z_score * -16.5 + 50 unless z_score.nil?
     self.destroy
  end

  def destroy_if_outlier
    if !self.z_score.nil?
      if self.z_score > 3.5
        self.destroy
        puts "ticket destroyed".red
      end
    end
  end

  def converted_row(row)
    letters = ('A'..'Z').to_a
    if letters.include?(row)
      converted_letters = {}
      letters.each_with_index{ |letter, i| converted_letters.merge!(letter => i +1) }
      return converted_letters[row].to_i
    elsif row[0].match /[a-zA-Z]/
      return row[1].to_i
    else
      return row.to_i
    end
  end
end