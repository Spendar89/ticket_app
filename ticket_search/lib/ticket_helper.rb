require 'open-uri'
require_relative 'oracle_arena_sections'

module TicketHelper
  class Tickets
    attr_accessor :team_name

    def initialize(team_name, set_game_id = false, price_min = 1, price_max = 10000, arena_hash = $oracle_arena_hash)
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
        if ticket["cp"].to_i >= @price_min && ticket["cp"].to_i < @price_max
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