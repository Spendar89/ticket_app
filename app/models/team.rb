class Team < ActiveRecord::Base
  attr_accessible :best_game_id, :name, :arena_image, :games, :url, :section_averages, :section_standard_deviations
  has_many :games, :inverse_of => :team
  serialize :section_averages, Hash
  serialize :section_standard_deviations, Hash


  def make_games
    array = []
    SeatGeek::Connection.events({:q => self.name, :per_page => 15})['events'].each do |game_info|
      game_info["performers"].each do |team|
           array << game_info  if team["name"] == self.name && team["home_team"] == true
      end
    end
    array
  end

  def get_url
    TicketHelper::Tickets.team_url(self.name)
  end

  def home_average_price
    average_price = []
    self.games.each do |game|
        average_price << game[:average_price]
    end
    return average_price.inject(0){|result, sum| sum + result}/(average_price.length)
  end

  def home_average_popularity
    pop_array = []
    games.each do |game|
      pop_array << game.popularity
    end
    pop_array.inject(0){|sum, result| sum+result}/(pop_array.length) unless pop_array.length == 0
  end

  def home_standard_deviation
    array = []
    games.each do |game|
      array << (home_average_popularity - game[:popularity]) **2
    end
    Math.sqrt(array.inject(0){|sum, result| sum+result}/(array.length)) unless array.length == 0
  end

  def home_price_standard_deviation
    array = []
   self.games.each do |game|
      array << (home_average_price - game[:average_price]) **2
    end
    Math.sqrt(array.inject(0){|sum, result| sum+result}/(array.length)) unless array.length == 0
  end

  def best_game
    games ={}
    array = []
    games.each do |game|
      games.merge!( game => game.affordability_index )
    end
    games.each_pair{|key, value| array << value}
    games.key(array.sort[-1])
  end

  def get_section_averages
    section_array = []
    self.games.each { |game| section_array << game.section_averages }
    new_hash = {}
    section_array.each do |hash|
      hash.each do |key, value|
        if new_hash.has_key?(key)
          new_hash[key][:price] += value[:price]
          new_hash[key][:number] += value[:number]
        else
          new_hash.merge!(key => value)
        end
      end
    end
    final_hash = {}
    new_hash.each { |key, value| final_hash.merge!({key => value[:price]/value[:number]}) }
    final_hash
  end

  def get_section_standard_deviations
    section_array = []
    self.games.each { |game| section_array << game.section_standard_deviations }
    new_hash = {}
    section_array.each do |hash|
      hash.each do |key, value|
        if new_hash.has_key?(key)
          new_hash[key][:variance] += value[:variance]
          new_hash[key][:number] += value[:number]
        else
          new_hash.merge!(key => value)
        end
      end
    end
    final_hash = {}
    new_hash.each { |key, value| final_hash.merge!({key => Math.sqrt(value[:variance]/value[:number]).to_i}) }
    final_hash
  end

end