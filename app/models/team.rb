class Team < ActiveRecord::Base
  attr_accessible :best_game_id, :name, :arena_image, :games, :url, :section_averages, :section_standard_deviations, :seat_views, :venue_name, :venue_address, :division, :last_5, :conference, :record
  has_many :games, :inverse_of => :team
  serialize :section_averages, Hash
  serialize :section_standard_deviations, Hash
  serialize :seat_views, Hash


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

  def set_attributes
    venue_info = get_venue_info['venue']
    self.update_attributes(:venue_name => venue_info['name'], :venue_address => "#{venue_info['address']}, #{venue_info['city']}, #{venue_info['state']}",
                            :conference => get_team_stats[:conference], :division => get_team_stats[:division])
    update_team_stats
  end

  def update_team_stats
    self.update_attributes(:record => get_team_stats[:record], :last_5 => get_team_stats[:last_5])
  end

  def get_venue_info
    SeatGeek::Connection.events({:q => self.name, :per_page => 15})['events'].each do |game_info|
      game_info["performers"].each do |team|
           return game_info if team["name"] == self.name && team["home_team"] == true
      end
    end
  end

  def get_team_stats
    standings_hash = JSON.parse(open('http://erikberg.com/nba/standings.json').read)['standing']
    wins = standings_hash.select{|f| self.name.include?(f["last_name"])}[0]['won']
    losses = standings_hash.select{|f| self.name.include?(f["last_name"])}[0]['lost']
    conference = standings_hash.select{|f| self.name.include?(f["last_name"])}[0]['conference'].downcase
    division = standings_hash.select{|f| self.name.include?(f["last_name"])}[0]['division'].downcase
    last_5 = standings_hash.select{|f| self.name.include?(f["last_name"])}[0]['last_five']
    { :record => "#{wins}-#{losses}", :conference => conference, :division => division, :last_5 => last_5 }
  end

  def get_team_record
    get_team_stats[:record]
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

  def get_seat_views
    sections_array = TicketHelper::Tickets.new(self.name, self.games.first).sections_available
    seat_views_hash = {}
    game = self.games.first
    sections_array.each do |section|
      seat_views_hash.merge!("#{section.to_i}" => image_url(game[:venue], section))
    end
    self.update_attributes(:seat_views => seat_views_hash)
  end

  def image_url(venue, section)
    url = open("http://api.avf.ms/venue.php?jsoncallback=?key=33970eb4232b8bd273dd548da701abd2&venue=#{URI.escape(venue)}&section=#{section}").read
    hash = JSON.parse("{#{url.scan(/"image":"\w+-\d+.jpg"/)[0]}}")
    if !hash['image'].nil?
      "http://aviewfrommyseat.com/wallpaper/#{hash['image']}"
    else
      false
    end
  end

end