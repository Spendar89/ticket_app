class Game < ActiveRecord::Base
  attr_accessible :popularity, :average_price, :date, :opponent, :stubhub_id, :team_id, :other_games, :relative_popularity
  belongs_to :team, :inverse_of => :games
  has_many :tickets
  validates :stubhub_id, :format => { :with => /^\d{7}$/}, :uniqueness => true

    def set_attributes(game_hash)
      @game_hash = game_hash
      fill_in_attributes
    end

    def fill_in_attributes
      self.popularity = popularity
      self.date = date
      self.opponent = opponent
      self.latitude = latitude
      self.longitude = longitude
      self.venue = venue
      self.stubhub_id = TicketHelper::Tickets.game_id(self)
      self.save
    end

    def determine_relatives
      self.update_attributes(:relative_popularity => relative_popularity, :average_price => self.tickets.average(:price))
    end
    

    def opponent
       @game_hash["performers"].each{ |team| return team["name"] if team["name"] != self.team.name}
    end

    def venue
      @game_hash["venue"]["name"]
    end

    def latitude
      @game_hash["venue"]["location"]["lat"]
    end

    def longitude
      @game_hash["venue"]["location"]["lon"]
    end

    def date
      Date.parse(@game_hash["datetime_local"]).strftime("%-m-%-d-%Y")
    end

    def popularity
      @game_hash["score"]*100
    end

    def relative_popularity
      if self.team[:pop_std_dev] != 0
        z_score = ((self[:popularity] - self.team[:average_popularity])/self.team[:pop_std_dev]).to_f
        (z_score*16.5 + 50).to_f
      end
    end

    def popularity_multiplier
      if self.team[:pop_std_dev] != 0
        z_score = ((self[:popularity] - self.team[:average_popularity])/(self.team[:pop_std_dev])).to_f
        ((z_score + 4)/4).to_f
      end
    end

    def refresh_tickets
      updated_tickets = TicketHelper::Tickets.new(self.team[:name], self, 1, 2000).all_available
      puts "received tickets array for #{self.team[:name]} against #{self[:opponent]}".blue
      updated_tickets.map! do |ticket|
        section_id = self.team.sections.find_by_name(ticket[0][:section]).id unless self.team.sections.find_by_name(ticket[0][:section].downcase).nil?
        self.tickets.new(:price => ticket[0][:price], :quantity => ticket[0][:quantity], :row => ticket[0][:row],
                            :section_id => section_id, :stubhub_id => ticket[0][:stubhub_id].to_i, :url => ticket[0][:url])
      end
      puts "beginning import...".yellow
      self.tickets.import updated_tickets
      puts "import complete".green
    end

    def best_ticket(price_min, price_max)
      tickets_array = {}
      self.tickets.each do |ticket|
        tickets_array.merge!(ticket[:id] => ticket.seat_value.to_f) unless ticket.seat_value.to_s.to_i == 0 || ticket[:price] > price_max || ticket[:price] < price_min
      end
      sorted_tickets = tickets_array.sort_by{|key, value| value}
      if sorted_tickets.length >= 10
        sorted_tickets = sorted_tickets[-10..-1]
      else
        sorted_tickets = sorted_tickets[0..-1]
      end
      begin
        sorted_tickets.reverse
        rescue Exception => exc
      end
      
    end

    def destroy_outliers
      self.tickets.find_each{|ticket| ticket.destroy_if_outlier }
    end
    
    def view_game_data(price_min, price_max, number)
        number = number - 1
        game_info = {}
        best_ticket_hash = best_ticket(price_min, price_max)[number]
        return false if best_ticket_hash.nil?  
        best_ticket = self.tickets.find(best_ticket_hash[0])
        {:best_ticket => best_ticket, :average_ticket_price => self.tickets.average(:price).to_i, 
        :seat_rating => best_ticket_hash[1].to_i, :game_rating => self[:relative_popularity], 
        :overall_rating => ((best_ticket_hash[1]/2) + (self[:relative_popularity]/2)).to_i }
    end
end


