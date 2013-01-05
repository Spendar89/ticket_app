class Game < ActiveRecord::Base
  attr_accessible :date, :opponent, :stubhub_id, :team_id, :game_rating, :game_hash
  attr_accessor :tickets, :average_price, :game_hash
  belongs_to :team, :inverse_of => :games
  validates :id, :format => { :with => /^\d{7}$/}, :uniqueness => true, :on => :create
    
    def set_attributes(game_hash)
      @game_hash = game_hash
      stubhub_id = StubHub::TicketFinder.game_id(self.team[:url], set_date)
      self.id = stubhub_id unless stubhub_id.is_a? Array
      self.date = set_date
      self.opponent = set_opponent
      self.game_rating = game_rating
      self.save  
    end
    
    def tickets
      redis_tickets.map{|ticket_id| $redis.hgetall "ticket:#{ticket_id}"}
    end
    
    def self.tickets(game_id)
      self.redis_tickets(game_id).map{|ticket_id| $redis.hgetall "ticket:#{ticket_id}"}
    end
  
    def redis_tickets
      $redis.zrange "tickets_for_game_by_price:#{self[:id]}", 0, -1
    end
    
    def self.redis_tickets(game_id)
      $redis.zrange "tickets_for_game_by_price:#{game_id}", 0, -1
    end
    
    def self.number_of_tickets(game_id)
      $redis.zcard "tickets_for_game_by_price:#{game_id}"
    end
    
    def number_of_tickets
      $redis.zcard "tickets_for_game_by_price:#{self[:id]}"
    end
    
    def average_price
      $redis.zscore "games:average_price", self[:id]
    end
    
    def self.average_price(game_id)
      unless self.number_of_tickets(game_id) == 0
        prices = self.tickets(game_id).map { |ticket| ticket['price'].to_i }
        prices_sum = prices.inject(0){|x, y| x + y }
        prices_sum/self.number_of_tickets(game_id)
      end
    end
      
    def opponent_object
      Team.find_by_name(self[:opponent])
    end
  
    def set_opponent
       @game_hash["performers"].each{ |team| return team["name"] if team["name"] != self.team[:name]}
    end

    def set_date
      Date.parse(@game_hash["datetime_local"])
    end

    def game_rating
      opp  = opponent_object
      record_array = opp[:record].split("-")
      record_rating = ((record_array[0].to_f/(record_array[0].to_f + record_array[1].to_f)).to_f) * 100
      (opp.stars.sum(:rating).to_f + record_rating).to_i
    end

    def add_to_redis_tickets
      StubHub::TicketFinder.new(self.team, self, 1, 5000).add_to_redis_tickets
    end

    def best_tickets_array(price_min, price_max)
      game_id = self[:id] 
      ticket_prices = $redis.zrangebyscore "tickets_for_game_by_price:#{game_id}", price_min, price_max
      $redis.pipelined do  
        ticket_prices.each { |ticket_id| $redis.sadd "game:#{game_id}:tickets:filtered:price:#{price_min}:#{price_max}", ticket_id }
      end
      $redis.zinterstore("game:#{game_id}:tickets:filtered:price:seat_values",  
                        ["game:#{game_id}:tickets:filtered:price:#{price_min}:#{price_max}", 
                        "tickets_for_game_by_seat_value:#{game_id}"])
      $redis.zrevrange "game:#{game_id}:tickets:filtered:price:seat_values", 0, -1, withscores: true
    end
    
    def valid_ticket?(ticket_hash, price_min, price_max)
      price = ticket_hash['price'].to_i
      true unless price > price_max || price < price_min || ticket_hash['section_id'].nil?
    end
    
    def view_game_data(price_min, price_max, number)
        number = number - 1
        best_redis_ticket = best_tickets_array(price_min, price_max)[number]
        return false if best_redis_ticket.nil?  
        get_game_rating = self[:game_rating]  
        best_ticket = Ticket.find(best_redis_ticket[0])
        {:best_ticket => best_ticket, :average_ticket_price => average_price, 
        :seat_rating => best_redis_ticket[1].to_i, :game_rating => get_game_rating, 
        :overall_rating => ((best_redis_ticket[1]/2) + (get_game_rating/2)).to_i }
    end
end


