require 'open-uri'
require_relative 'oracle_arena_sections'
require 'nokogiri'

module TicketHelper
  class Tickets
    attr_accessor :team_name

    def initialize(team_name, set_game = false, price_min = 1, price_max = 10000, arena_hash = $oracle_arena_hash)
      @team_name = team_name
      @price_min = price_min
      @price_max = price_max
      @team_name_url = team_name.gsub(' ', '-')
      @arena_hash = arena_hash
      @set_game = set_game
      @doc = Nokogiri::HTML(open("http://www.stubhub.com/#{@team_name_url}-tickets/"))
    end


    def urls
      array = []
      @doc.css('td[class="eventName"]').each do |node|
        array << node.elements.css("a").attr("href")
      end
      array
    end

    def self.team_url(team_name)
      team_name_url = team_name.gsub(' ', '-')
      doc = "http://www.stubhub.com/#{team_name_url}-tickets/"
    end

    def best_game_id
      if @set_game_id == false
        best_game_date = Team.new(@team_name).best_game.date
        urls.each{ |url| return url.to_s.split("-")[-1][0...-1] if /#{best_game_date}/.match(url) }
      else
        return @set_game[:stubhub_id]
      end
    end

    def self.game_id(game)
      game_date = game[:date]
      team_url = Nokogiri::HTML(open(game.team.url))
      all_game_urls = []
      team_url.css('td[class="eventName"]').each do |node|
      all_game_urls << node.elements.css("a").attr("href")
      end
      all_game_urls.each{ |url| return url.to_s.split("-")[-1][0...-1] if /#{game_date}/.match(url) }
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
          tickets_array << [{:game_info => game_data[:game_info], :url => "http://www.stubhub.com/#{@team_name_url}-tickets/#{game_data[:url]}?ticket_id=#{ticket['id']}",
          :ticket_id => ticket["id"], :price => ticket["cp"].to_i,:row => ticket["rd"],
          :quantity => ticket["qt"], :section => get_section(ticket["st"]), :seats => ticket["se"]}]
        end
      end
      tickets_array
    end

    def get_section(hash_data)
      relevent = hash_data.scan(/(\d{1,3}|A\d)/)
      return relevent[0][0].to_i
    end

    def sections_available
      sections = []
      best_all_available.each do |available|
        sections << available[2].to_i unless sections.include?(available[2].to_i)
      end
      sections
    end

    def find_seat_value(section, row)
        section_value = @set_game.team[:section_averages][section]
        row_value = ""
        case row_value
          when row == "AA"; -5
          when row == "A1"; 1
          when row == "A2"; 2
          when row == "A3"; 3
          when row == "A4"; 4
          when row == "A5"; 5
          else
            if row.to_i > 0
              row_value = row.to_i
            else
              row_value = converted_letter_row(row)
            end
        end
       {:raw_value => section_value - row_value, :standard_deviation => section_value}
    end

    def converted_letter_row(row)
      letters = ('A'..'Z').to_a
      converted_letters = {}
      letters.each_with_index do |letter, i|
        converted_letters.merge!(letter => i +1)
      end
      converted_letters[row].to_i
    end

    def converted_seats
      converted_seats = []
      best_all_available.each do |seat|
        converted_seats << [{:ticket_id => seat[0][:ticket_id], :price => seat[0][:price],  :value => find_seat_value(seat[0][:section].to_i, seat[0][:row])}]
      end
      converted_seats
    end

    def value_index
      values = {}
      converted_seats.each do |seat|
        values.merge!(seat[0][:ticket_id] => {:price => seat[0][:price], :index => standard_value(seat) })
      end
      values
    end

    def standard_value(seat)
      price_difference = seat[0][:price].to_f - seat[0][:value][:raw_value].to_f
      standard_deviation = seat[0][:value][:standard_deviation].to_f
      converted_z_score = (price_difference/standard_deviation).to_f * 16.5 + 50
      100 - converted_z_score.to_i
    end

    def

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
      best_all_available.each{ |seat| return seat[0].merge(:ticket_rating => (best[1]).to_i) if seat[0][:ticket_id] == best[0] }
    end

    def sorted_tickets
      test = {}
      value_index.each_pair do |seat_id, values|
          test.merge!(seat_id => values[:index])
      end
      test.sort_by{|key, value| value}
    end

    def section_averages
      test_hash = {}
      best_all_available.sort!{|seat_1, seat_2| seat_1[0][:price] <=> seat_2[0][:price]}.each do |seat|
        seat_price = seat[0][:price]
        if test_hash.has_key?(seat[0][:section])
          test_hash[seat[0][:section]][:price] +=  seat_price if seat_price/4 < (test_hash[seat[0][:section]][:price]/test_hash[seat[0][:section]][:number])
          test_hash[seat[0][:section]][:number] += 1
        else
          test_hash.merge!(seat[0][:section] => {:price => seat_price, :number => 1})
        end
      end
      test_hash
    end

    def section_standard_deviations
      test_hash = {}
      best_all_available.sort!{|seat_1, seat_2| seat_1[0][:price] <=> seat_2[0][:price]}.each do |seat|
        price = seat[0][:price]
        average = @set_game.team.section_averages[seat[0][:section]]
        if test_hash.has_key?(seat[0][:section])
          variance = test_hash[seat[0][:section]][:variance]
          number = test_hash[seat[0][:section]][:number]
          test_hash[seat[0][:section]][:variance] += (price - average)**2 if ((price - average)**2)/2 <  variance/number
          test_hash[seat[0][:section]][:number] += 1
        else
          test_hash.merge!(seat[0][:section] => {:variance => (price - average)**2, :number => 1})
        end
      end
      test_hash
    end

  end
end

