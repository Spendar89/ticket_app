require 'seatgeek'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'watir-webdriver'
require 'selenium/server'
require_relative 'oracle_arena_sections.rb'

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

class Tickets
  def initialize(team_name)
    @team_name = team_name
    @team_name_url = team_name.gsub(' ', '-')
    @doc = Nokogiri::XML(open("http://www.ticketsnow.com/#{@team_name_url}-tickets/"))
  end

  def urls
    array = []
    @doc.css('a[class="url summary"]').each do|node|
      array << node.values[1]
    end
    array
  end

  def best_game_url
    best_game = TeamGames.new(@team_name).best_game.date
    urls.each do |url|
      if /#{best_game}/.match(url.to_s)
        return url
      end
    end
  end

  def all_available
    available = []
    doc = Nokogiri::HTML(open(best_game_url))
    seats= doc.css('div[id="ucTicketList_divTicketListContainer"] script[type="text/javascript"]').to_s.split('SECTION SEATING')
    seats[1..-1].each_with_index do |seat,i|
      entry = seat.split(',')[1..5]
      entry.delete_at(1)
      available << entry.map!{|line| line.split(':')[1].gsub(/"|"/, '')  } unless entry[2].match(/Parking/)
    end
    available.each_with_index{|seat, i| seat << "ticket_id_#{i}"}
  end

  def sections_available
    sections = []
    all_available.each do |available|
      sections << available[2].to_i unless sections.include?(available[2].to_i)
    end
    sections
  end

end

class Arena
  def initialize(tickets, section_hash)
    @tickets = tickets
    @section_hash = section_hash
  end

  def find_seat_value(section, row)
      section_value = section.to_i
      row_value = ""
      case row_value
        when row == "AA"; -5
        when row == "A1"; 1
        when row == "A2"; 2
        when row == "A3"; 3
        when row == "A4"; 4
        when row == "A5"; 5
        else
          row_value = row.to_i
      end
      100-(section_value + row_value)
  end

  def converted_seats
    converted_seats = []
    @tickets.all_available.each do |seat|
      converted_seats << [seat[-1], seat[0],  find_seat_value(@section_hash[seat[2]], seat[3])]
    end
    converted_seats
  end

  def value_index
    values = {}
    converted_seats.each do |seat|
      values.merge!(seat[0] => {:price => seat[1], :index => seat[2].to_f/seat[1].to_f})
    end
    values
  end

  def best_ticket(min_price)
    test = {}
    value_index.each_pair do |seat_id, values|
      if values.first[1].to_f > min_price.to_f
        test.merge!(seat_id => values[:index])
      end
    end
    best_ticket = test.sort_by{|key, value| value}.last
    return best_ticket
  end

  def get_best_ticket(min_price)
    best = best_ticket(min_price)
    @tickets.all_available.each_with_index do |seat, i|
        if seat[-1] == best[0]
          return seat
        end
    end
  end

  def best_ticket_full_info(min_price)
    game = TeamGames.new("Golden State Warriors").best_game
    ticket = get_best_ticket(min_price)
    "date: #{game.date}\n
    opponent: #{game.opponent}\n
    price: #{ticket[0]}\n
    quantity: #{ticket[1]}\n
    section: #{ticket[2]}\n
    row: #{ticket[3]}\n"
  end

end

tickets = Tickets.new("Golden State Warriors")
puts Arena.new(tickets, $oracle_arena_hash).best_ticket_full_info(25)
# 165
# 2
# 115
# 2
# ticket_id_408