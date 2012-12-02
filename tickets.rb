require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'json'
require_relative 'team_games'

class Tickets
  def initialize(team_name, price_min, price_max)
    @team_name = team_name
    @price_min = price_min
    @price_max = price_max
    @team_name_url = team_name.gsub(' ', '-')
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
    best_game_date = TeamGames.new(@team_name).best_game.date
    urls.each do |url|
      if /#{best_game_date}/.match(url)
        return url.to_s.split("-")[-1][0...-1]
      end
    end
  end

  def best_json_data
    # url = open("http://www.stubhub.com/ticketAPI/restSvc/event/#{best_game_id}").read
    url = open("http://www.stubhub.com/ticketAPI/restSvc/event/4118684").read
    json_data = JSON.parse(url)['eventTicketListing']
    return {:game_info => json_data['event']['seoTitle'], :url => json_data['eventUrlPath'], :data => json_data['eventTicket']}
  end

  def best_all_available
    game_data = best_json_data
    tickets_array = []
    game_data[:data].each do |ticket|
      if ticket["cp"].to_i >= @price_min && ticket["cp"].to_i <= @price_max
        tickets_array << [{:game_info => game_data[:game_info], :url => "http://www.stubhub.com/#{@team_name_url}-tickets/#{game_data[:url]}?ticket_id=#{ticket['id']}", :ticket_id => ticket["id"], :price => ticket["cp"].to_i,:row => ticket["rd"],
          :quantity => ticket["qt"],:section => ticket["st"].scan(/(\d{1,3}|A\d)/)[0][0].to_i,:seats => ticket["se"]}]
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

end

# tickets = Tickets.new("Golden State Warriors", 100, 200).best_game_id
# puts tickets