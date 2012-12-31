class Ticket < ActiveRecord::Base
  attr_accessible :game_id, :price, :quantity, :row, :section_id, :stubhub_id, :url, :z_score
  attr_accessor :redis_id
  # belongs_to :game
  # belongs_to :section, :inverse_of => :tickets
  # validates :stubhub_id, :numericality => true, :presence => true
  # validates :url, :section_id, :presence => true
  
  def initialize(redis_id)
    super()
    @redis_id = redis_id.to_i
    redis_hash = $redis.hgetall "ticket:#{@redis_id}"
    @section_hash = $redis.hgetall "section:#{redis_hash['section_id']}"
    self.game_id = redis_hash["game_id"]
    self.price = redis_hash["price"]
    self.quantity = redis_hash["quantity"]
    self.row = redis_hash["row"]
    self.section_id = redis_hash["section_id"]
    self.stubhub_id = redis_hash["stubhub_id"]
    self.url = redis_hash["url"] 
  end
  
  def game
    Game.find(self.game_id)
  end
  
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
      # z_score > 3.5 ? destroy(ticket_has) : z_score
    end
  end
  
  def calculated_z_score
    return if ticket_hash['section_id'].to_i.nil?
    price = ticket_hash['price']
    if !price.nil? && !section_hash['average_price'].nil? && section_hash['std_dev'].to_f > 0
      row = Ticket.converted_row(ticket_hash['row']) * 2
      price_difference = (price.to_f + row) - section_hash['average_price'].to_f
      section_std_dev = section_hash['std_dev'].to_f
      z_score = (price_difference/section_std_dev).to_f
      # z_score > 3.5 ? destroy(ticket_has) : z_score
    end
  end
  
  def destroy
    $redis.del "ticket:#{@redis_id}"
    nil
  end
  
  def section
    Section.find(self.section_id)
  end
  
  def self.seat_value(section_id, price, row)
    section_hash = $redis.hgetall "section:#{section_id}"
    z_score = self.calculated_z_score(section_id, price, row, section_hash)
    z_score * -16.5 + 50 unless z_score.nil?
  end
  
  def seat_value(ticket_hash)
    section_hash = $redis.hgetall "section:#{ticket_hash['section_id']}"
    z_score = calculated_z_score(ticket_hash, section_hash)
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