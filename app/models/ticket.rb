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
    z_score * -12.5 + 50 unless z_score.nil?
    
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
  
  
  def self.redis_pipeline(ticket, game_id)
    seat_value = self.seat_value(ticket[:section_id].to_i, ticket[:price], ticket[:row])
    ticket_id = ticket[:ticket_id]
    unless seat_value.to_i < 0 || seat_value.nil? || ticket[:section_id].nil?
        $redis.pipelined do
          $redis.hmset "ticket:#{ticket[:ticket_id]}", :price, ticket[:price], :quantity, ticket[:quantity], :row, ticket[:row], 
          :section_id, ticket[:section_id].to_i, :stubhub_id, ticket_id, :url, ticket[:url], 
          :game_id, game_id, :seat_value,  seat_value
          $redis.expire "ticket:#{ticket_id}", 7200             
          $redis.zadd "tickets_for_game_by_seat_value:#{game_id}", seat_value, ticket_id
          $redis.zadd "tickets_for_game_by_price:#{game_id}", ticket[:price], ticket_id
          $redis.zadd "tickets_for_section_by_price:#{ticket[:section_id]}", ticket[:price], ticket_id
      end
    end
  end
  
  
  def self.update_redis(team_id, game_id)
    if  /^\d{7}$/.match(game_id.to_s) 
      puts "finding tickets for #{game_id}...".blue
      all_tickets = StubHub::TicketFinder.tickets(team_id, game_id)
      all_tickets.each { |ticket| self.redis_pipeline(ticket, game_id) }
      puts "tickets added for #{game_id}"
    end
  end
  
end