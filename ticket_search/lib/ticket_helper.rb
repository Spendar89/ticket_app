require 'open-uri'
require_relative 'oracle_arena_sections'
module TicketHelper

  class Game
    attr_accessor :team_name, :other_games

    def initialize(team_name, game_info_hash)
      @game_info = game_info_hash
      @team_name = team_name
      @other_games = Team.new(@team_name)
    end

    def average_price
      @game_info["stats"]["average_price"]
    end

    def home?
      @game_info["performers"].each{ |team| return true  if team["name"] == @team_name && team["home_team"] == true }
      false
    end

    def opponent
       @game_info["performers"].each{ |team| return team["name"] if team["name"] != @team_name }
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
    attr_accessor :team_name

    def initialize(team_name, set_game_id = false, price_min = 600, price_max = 10000, arena_hash = $oracle_arena_hash)
      @team_name = team_name
      @price_min = price_min
      @price_max = price_max
      @team_name_url = team_name.gsub(' ', '-')
      @arena_hash = arena_hash
      @set_game_id = set_game_id
      @doc = Nokogiri::HTML(open("http://www.stubhub.com/#{@team_name_url}-tickets/"))
    end


    def urls
      array = []
      new_array =[]
      @doc.css('td[class="eventName"]').each do |node|
        array << node.elements.css("a").attr("href")
      end
      array
    end

    def best_game_id
      if @set_game_id == false
        best_game_date = Team.new(@team_name).best_game.date
        urls.each{ |url| return url.to_s.split("-")[-1][0...-1] if /#{best_game_date}/.match(url) }
      else
        return @set_game_id.to_s
      end
    end

    def best_json_data
      url = open("http://www.stubhub.com/ticketAPI/restSvc/event/#{best_game_id}").read
      json_data = JSON.parse(url)['eventTicketListing']
      return {:game_info => json_data['event']['seoTitle'], :url => json_data['eventUrlPath'], :data => json_data['eventTicket']}
    end

    def best_all_available
      game_data = best_json_data
      tickets_array = []
      game_data[:data].each do |ticket|
        if ticket["cp"].to_i >= @price_min && ticket["cp"].to_i < @price_max && !ticket["st"].scan(/(\d{1,3}|A\d)/)[0].nil?
          tickets_array << [{:game_info => game_data[:game_info], :url => "http://www.stubhub.com/#{@team_name_url}-tickets/#{game_data[:url]}?ticket_id=#{ticket['id']}", :ticket_id => ticket["id"], :price => ticket["cp"].to_i,:row => ticket["rd"], :quantity => ticket["qt"], :section => ticket["st"].scan(/(\d{1,3}|A\d)/)[0][0].to_i,:seats => ticket["se"]}]
        end
      end
      tickets_array
    end

    def sections_available
      sections = []
      best_all_available.each do |available|
        sections << available[2].to_i unless sections.include?(available[2].to_i)
      end
      sections
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
      best_all_available.each do |seat|
        converted_seats << [{:ticket_id => seat[0][:ticket_id], :price => seat[0][:price],  :value => find_seat_value(@arena_hash[seat[0][:section].to_s], seat[0][:row])}]
      end
      converted_seats
    end

    def value_index
      values = {}
      converted_seats.each do |seat|
        values.merge!(seat[0][:ticket_id] => {:price => seat[0][:price], :index => seat[0][:value].to_f/seat[0][:price].to_f})
      end
      values
    end

    def sorted_tickets
      test = {}
      value_index.each_pair do |seat_id, values|
          test.merge!(seat_id => values[:index])
      end
      test.sort_by{|key, value| value}
    end

    def average_value_index
      sorted_tickets.inject(0){|total, value| total + value[1]}/sorted_tickets.length
    end

    def standard_deviation
      variance = []
      sorted_tickets.each do |pair|
        variance << (pair[1] - average_value_index)**2
      end
      Math.sqrt(variance.inject(0){|total, value| total + value}/variance.length)
    end

    def best_ticket
      best = sorted_tickets.last
      best_all_available.each{ |seat| return seat << [(best[1]*100).to_i, (average_value_index*100).to_i] if seat[0][:ticket_id] == best[0] }
    end

  end

  class Team

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

end

