class Game < ActiveRecord::Base
  attr_accessible :average_popularity, :average_price, :date, :opponent, :stubhub_id, :team_id, :game_hash, :other_games, :relative_popularity, :relative_price
  belongs_to :team

  before_save :fill_in_attributes
  after_save :determine_relatives

    def set_attributes(game_hash)
      @game_hash = game_hash
      @other_games = Team.find(self.team_id)
      @team_name = Team.find(self.team_id).name
      self.save
      self
    end

    def fill_in_attributes
      self.average_popularity = popularity
      self.average_price = average_price
      self.date = date
      self.home = home?
      self.opponent = opponent
      self.latitude = latitude
      self.longitude = longitude
      self.venue = venue
    end

    def determine_relatives
      self.update_attributes(:relative_popularity => relative_popularity, :relative_price => relative_price)
    end

    def average_price
      @game_hash["stats"]["average_price"]
    end

    def home?
      @game_hash["performers"].each{ |team| return true  if team["name"] == @team_name && team["home_team"] == true }
      false
    end

    def opponent
       @game_hash["performers"].each{ |team| return team["name"] if team["name"] != @team_name}
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
      if @other_games.home_standard_deviation != 0
        z_score =((popularity - @other_games.home_average_popularity)/(@other_games.home_standard_deviation))
        20*z_score + 40
      end
    end

    def relative_price
      if @other_games.home_price_standard_deviation != 0
        z_score = ((average_price - @other_games.home_average_price)/@other_games.home_price_standard_deviation)
        20*z_score + 40
      end
    end

    def affordability_index
      (relative_popularity/relative_price)*50
    end

end
