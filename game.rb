require 'date'

class Game
  attr_accessor :team_name, :other_games

  def initialize(team_name, game_info_hash)
    @game_info = game_info_hash
    @team_name = team_name
    @other_games = TeamGames.new(@team_name)
  end

  def average_price
    @game_info["stats"]["average_price"]
  end

  def home?
    @game_info["performers"].each do |team|
      if team["name"] == @team_name && team["home_team"] == true
        return true
      end
    end
    false
  end

  def opponent
     @game_info["performers"].each do |team|
        if team["name"] != @team_name
          return team["name"]
        end
      end
  end

  def venue
    @game_info["venue"]["name"]
  end

  def latitude
    @game_info["venue"]["location"]["lat"]
  end

  def longitude
    @game_info["venue"]["location"]["lon"]
  end

  def date
    Date.parse(@game_info["datetime_local"]).strftime("%m-%d-%Y")
  end

  def popularity
     @game_info["score"]*100
  end

  def relative_popularity
    z_score =((self.popularity - @other_games.home_average_popularity)/@other_games.home_standard_deviation)
    20*z_score + 40
  end

  def relative_price
    z_score = ((self.average_price - @other_games.home_average_price)/@other_games.home_price_standard_deviation)
    20*z_score + 40
  end

  def affordability_index
    (relative_popularity/relative_price)*50
  end

end

