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

    def get_stubhub_id
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

    def json_data
      url = open("http://www.stubhub.com/ticketAPI/restSvc/event/#{get_stubhub_id}").read
      json_data = JSON.parse(url)['eventTicketListing']
      return {:game_info => json_data['event']['seoTitle'], :url => json_data['eventUrlPath'], :data => json_data['eventTicket']}
    end

    def all_available
      game_data = json_data
      tickets_array = []
      game_data[:data].each do |ticket|
        if ticket["cp"].to_i >= @price_min && ticket["cp"].to_i < @price_max && !ticket["st"].scan(/(\d{1,3}|A\d)/)[0].nil?
          tickets_array << [{:game_info => game_data[:game_info], :url => "http://www.stubhub.com/#{@team_name_url}-tickets/#{game_data[:url]}?ticket_id=#{ticket['id']}",
          :stubhub_id => ticket["id"], :price => ticket["cp"].to_i,:row => ticket["rd"],
          :quantity => ticket["qt"], :section => ticket["st"], :seats => ticket["se"]}]
        end
      end
      tickets_array
    end


  end
end

