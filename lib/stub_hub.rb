require 'open-uri'
require 'nokogiri'

module StubHub
  class TicketFinder
    attr_accessor :team_name

    def initialize(team, set_game = false, price_min = 1, price_max = 5000)
      @team = team
      @team_name = @team[:name]
      @price_min = price_min
      @price_max = price_max
      @team_name_url = @team_name.gsub(' ', '-')
      @set_game = set_game
    end


    def urls
      doc =  Nokogiri::HTML(open("http://www.stubhub.com/#{@team_name_url}-tickets/"))
      array = []
      doc.css('td[class="eventName"]').each do |node|
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
        return @set_game[:id]
      end
    end

    def self.game_id(team_url, game_date)
      game_date =  game_date.strftime("%-m-%-d-%Y")
      team_url = Nokogiri::HTML(open(team_url))
      all_game_urls = []
      team_url.css('td[class="eventName"]').each do |node|
        all_game_urls << node.elements.css("a").attr("href")
      end
      all_game_urls.each{ |url| return url.to_s.split("-")[-1][0...-1] if /#{game_date}/.match(url) }
    end

    def self.json_data(game_stubhub_id)
      url = open("http://www.stubhub.com/ticketAPI/restSvc/event/#{game_stubhub_id}").read
      json_data = JSON.parse(url)['eventTicketListing']
      return {:game_info => json_data['event']['seoTitle'], :url => json_data['eventUrlPath'], :data => json_data['eventTicket']}
    end
    
    def json_data
      url = open("http://www.stubhub.com/ticketAPI/restSvc/event/#{@set_game[:id]}").read
      json_data = JSON.parse(url)['eventTicketListing']
      return {:game_info => json_data['event']['seoTitle'], :url => json_data['eventUrlPath'], :data => json_data['eventTicket']}
    end

    def all_available
      game_data = json_data
      tickets_array = []
      game_data[:data].each do |ticket|
        if ticket["cp"].to_i >= @price_min && ticket["cp"].to_i < @price_max && !ticket["va"].scan(/(\d{1,3}|A\d)/)[0].nil?
          tickets_array << [{:game_info => game_data[:game_info], :url => "http://www.stubhub.com/#{@team_name_url}-tickets/#{game_data[:url]}?ticket_id=#{ticket['id']}",
          :stubhub_id => ticket["id"], :price => ticket["cp"].to_i,:row => ticket["rd"],
          :quantity => ticket["qt"], :section => ticket["va"].downcase, :seats => ticket["se"]}]
        end
      end
      tickets_array
    end
    
    def self.team_name_url(team_id)
      name = $redis.hget "team:#{team_id}", 'name'
      name.gsub(' ', '-')
    end
    
    def self.tickets(team_id, game_id)
      tickets = []
      game_data = self.json_data(game_id)
      game_data[:data].each do |ticket|
        if !ticket["va"].scan(/(\d{1,3}|A\d)/)[0].nil?
          section_id = $redis.zscore "sections_for_team_by_name:#{team_id}", ticket['va'].downcase
          tickets << { :section_id => section_id , :price => ticket["cp"].to_i, :row => ticket["rd"], :ticket_id => ticket["id"].to_i, :quantity => ticket["qt"],
          :url =>  "http://www.stubhub.com/#{self.team_name_url(team_id)}-tickets/#{game_data[:url]}?ticket_id=#{ticket['id']}" } 
        end
      end
      tickets
    end
  
    
  end
end

