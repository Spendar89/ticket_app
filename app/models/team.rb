class Team < ActiveRecord::Base
  attr_accessible :get_stubhub_id, :name, :arena_image, :games, :url, :venue_name, :venue_address, :division, :last_5, :conference, :record, :average_popularity, :pop_std_dev
  has_many :games, :inverse_of => :team
  has_many :sections
  has_many :stars
  validates :url, :presence => true, :uniqueness => true
  
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

  def set_pop_std_dev
    average = self.games.average(:popularity)
    puts "average: #{average}".yellow
    squared = self.games.pluck(:popularity).collect{ |pop| (pop - average)**2 }
    puts "squared-sum: #{squared.inject(0){|x, y| x + y }}".yellow
    std_dev = Math.sqrt(squared.inject(0){|x, y| x + y }/self.games.length).to_f unless self.games.length < 1
    puts "std_dev: #{std_dev}".yellow
    self.update_attribute(:average_popularity, average)
    self.update_attribute(:pop_std_dev, std_dev)
    puts "updated std_dev and average_popularity".green
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


  def get_seat_views
    self.sections.all.each do |section|
      update_attributes(:seat_view_url => image_url(self[:venue_name], section[:name].scan(/\d{1,3}/)[-1]))
    end
  end

  def image_url(venue, section)
    url = open("http://api.avf.ms/venue.php?jsoncallback=?key=33970eb4232b8bd273dd548da701abd2&venue=#{URI.escape(venue)}&section=#{section}").read
    hash = JSON.parse("{#{url.scan(/"image":"\w+-\d+.jpg"/)[0]}}")
    unless hash['image'].nil?
      "http://aviewfrommyseat.com/wallpaper/#{hash['image']}"
    else
      false
    end
  end

  def get_sections
    puts "setting sections for #{self[:name]}".blue
    tickets = []
    self.games.find_each do |game|
      tickets << TicketHelper::Tickets.new(self.name, game, 1, 5000).all_available
    end
    tickets.each do |all_tickets|
      all_tickets.each do |ticket|
        self.sections.create(:name => ticket[0][:section])
      end
    end
  end
  
  def date_range?(game, date_start, date_end)
    converted_game_date = converted_date(game[:date])
    true if  converted_game_date >= converted_date(date_start) &&  converted_game_date <= converted_date(date_end)
  end
  
  def converted_date(date)
    Date.strptime(date, "%m-%d-%Y")  
  end
  
  def filtered_games(date_start, date_end)
    games = []
    total_tickets = 0
    self.games.find_each do |game| 
      games << game if date_range?(game, date_start, date_end)
      total_tickets += game.tickets.count 
    end
    {:games => games, :total_tickets => total_tickets}
  end
  
  def price_chart(price_data, rating_data)
    LazyHighCharts::HighChart.new('graph') do |f|
        f.chart!(:backgroundColor => 'transparent', :spacingRight => 40)
        f.title(:style=>{:color => 'transparent'})
        f.credits!({:enabled => false})
        f.options[:legend][:enabled] = false
        f.series(:name => 'average ticket price', :type => 'line', :data=> price_data, :xAxis => 1, :yAxis => 0, :line => {:lineWidth => 8, :color => "black"})
        f.series(:name => 'game score', :type => 'line', :data => rating_data, :xAxis => 1, :yAxis => 1, :line => {:lineWidth => 8, :color => "orange"})
        f.xAxis!([{:labels => {:enabled => false }}, {:labels => {:enabled => false }}])
        f.yAxis!([{:title => {:text => false}, :gridLineColor => 'transparent', :labels => {:enabled => false}}, 
                  {:title => {:text => false}, :gridLineColor => 'transparent', :labels => {:enabled => false}}])
    end
  end
  

  



end