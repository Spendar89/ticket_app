class Game < ActiveRecord::Base
  attr_accessible :popularity, :average_price, :date, :opponent, :stubhub_id, :team_id, :game_hash, :other_games, :relative_popularity, :relative_price, :popularity_multiplier
  belongs_to :team, :inverse_of => :games
  before_save :fill_in_attributes
  has_many :tickets


    def set_attributes(game_hash)
      @game_hash = game_hash
      self.save
      self.destroy if self[:stubhub_id].length > 12
    end

    def fill_in_attributes
      self.popularity = popularity
      self.date = date
      self.opponent = opponent
      self.latitude = latitude
      self.longitude = longitude
      self.venue = venue
      self.stubhub_id = TicketHelper::Tickets.game_id(self)
    end

    def best_ticket(price_min, price_max)
      TicketHelper::Tickets.new(self.team.name, self, price_min, price_max).best_ticket
    end

    def determine_relatives
      self.update_attributes(:relative_popularity => relative_popularity, :popularity_multiplier => popularity_multiplier)
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
      if self.team.popularity_standard_deviation != 0
        z_score =((self.popularity - self.team.average_popularity)/(self.team.popularity_standard_deviation)).to_f
        20*z_score + 40
      end
    end

    def popularity_multiplier
      if self.team.popularity_standard_deviation != 0
        z_score =((self.popularity - self.team.average_popularity)/(self.team.popularity_standard_deviation)).to_f
        ((z_score + 4)/3).to_f
      end
    end

    def refresh_tickets
      updated_tickets = TicketHelper::Tickets.new(self.team.name, self, 1, 2000).all_available
      updated_tickets.each do |ticket|
        section_id = self.team.sections.find_by_name(ticket[0][:section]).id unless self.team.sections.find_by_name(ticket[0][:section]).nil?
        self.tickets.create(:price => ticket[0][:price], :quantity => ticket[0][:quantity], :row => ticket[0][:row],
                            :section_id => section_id, :stubhub_id => ticket[0][:stubhub_id], :url => ticket[0][:url])
      end
    end

    def best_ticket(price_min, price_max)
      tickets_array = {}
      self.tickets.each do |ticket|
        tickets_array.merge!(ticket.id => ticket.seat_value.to_f) unless ticket.seat_value.to_s.to_i == 0 || ticket.price > price_max || ticket.price < price_min
      end
      tickets_array.sort_by{|key, value| value}[0]
    end

    def destroy_outliers
      self.tickets.each{|ticket| ticket.destroy_if_outlier }
    end
end


