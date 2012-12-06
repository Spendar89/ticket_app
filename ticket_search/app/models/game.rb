class Game < ActiveRecord::Base
  attr_accessible :popularity, :average_price, :date, :opponent, :stubhub_id, :team_id, :game_hash, :other_games, :relative_popularity, :relative_price
  belongs_to :team, :inverse_of => :games

  before_save :fill_in_attributes

    def set_attributes(game_hash)
      @game_hash = game_hash
      self.save
    end

    def fill_in_attributes
      self.popularity = popularity
      self.average_price = average_price
      self.date = date
      self.home = home?
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
      self.update_attributes(:relative_popularity => relative_popularity, :relative_price => relative_price)
    end

    def average_price
      @game_hash["stats"]["average_price"]
    end

    def home?
      @game_hash["performers"].each{ |team| return true  if team["name"] == self.team.name && team["home_team"] == true }
      false
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
      if self.team.home_standard_deviation != 0
        z_score =((self.popularity - self.team.home_average_popularity)/(self.team.home_standard_deviation))
        20*z_score + 40
      end
    end

    def relative_price
      if self.team.home_price_standard_deviation != 0
        z_score = ((average_price - self.team.home_average_price)/self.team.home_price_standard_deviation)
        20*z_score + 40
      end
    end

    def affordability_index
      (relative_popularity/relative_price)*50
    end

end
