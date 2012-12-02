require 'seatgeek'
require_relative 'game'

class TeamGames

  def initialize(full_team_name)
    @team_name = full_team_name
  end

  def to_s
    SeatGeek::Connection.events({:q => @team_name})['events']
  end

  def all_games
    games=[]
    SeatGeek::Connection.events({:q => @team_name, :per_page => 15})['events'].each do |game_info|
      games << Game.new(@team_name, game_info)
    end
    return games
  end

  def home_average_price
    average_price = []
    home_games.each do |game|
        average_price << game.average_price
    end
    return average_price.inject(0){|result, sum| sum + result}/(average_price.length)
  end

  def away_average_price
    average_price = []
    away_games.each do |game|
        average_price << game.average_price
    end
    return average_price.inject(0){|result, sum| sum + result}/(average_price.length)
  end

  def home_average_popularity
    pop_array = []
    home_games.each do |game|
      pop_array << game.popularity
    end
    pop_array.inject(0){|sum, result| sum+result}/(pop_array.length)
  end

  def home_standard_deviation
    array = []
    home_games.each do |game|
      array << (home_average_popularity - game.popularity) **2
    end
    Math.sqrt(array.inject(0){|sum, result| sum+result}/(array.length))
  end

  def home_price_standard_deviation
    array = []
    home_games.each do |game|
      array << (home_average_price - game.average_price) **2
    end
    Math.sqrt(array.inject(0){|sum, result| sum+result}/(array.length))
  end

  def away_price_standard_deviation
    array = []
    away_games.each do |game|
      array << (away_average_price - game.average_price) **2
    end
    Math.sqrt(array.inject(0){|sum, result| sum+result}/(array.length))
  end

  def home_games
    home_games = []
    all_games.each do |game|
      home_games <<  game unless !game.home?
    end
    return home_games
  end

  def away_games
    away_games = []
    all_games.each do |game|
      away_games <<  game unless game.home?
    end
    return away_games
  end

  def best_game
    games ={}
    array = []
    home_games.each do |game|
      games.merge!( game => game.affordability_index )
    end
    games.each_pair{|key, value| array << value}
    games.key(array.sort[-1])
  end

end

# TeamGames.new("Golden State Warriors").home_games.each do |game|
#   puts game.opponent
#   puts game.average_price
# end