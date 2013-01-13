class Ticket < ActiveRecord::Base
    
  def self.find(id)
    $redis.hgetall "ticket:#{id}"  
  end
  
  def self.calculated_z_score(section_id, price, row, section_hash)
    return if section_id.to_i.nil?
    if !price.nil? && !section_hash['average_price'].nil? && section_hash['std_dev'].to_f > 0
      row = Ticket.converted_row(row) * 2
      price_difference = (price.to_f + row) - section_hash['average_price'].to_f
      section_std_dev = section_hash['std_dev'].to_f
      z_score = (price_difference/section_std_dev).to_f
    end
  end
    
  def self.destroy(redis_id)
    $redis.del "ticket:#{redis_id}"
    nil
  end

  def self.seat_value(section_id, price, row)
    section_hash = $redis.hgetall "section:#{section_id}"
    z_score = self.calculated_z_score(section_id, price, row, section_hash)
    z_score * -16.5 + 50 unless z_score.nil?
  end
  
  def self.converted_row(row)
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