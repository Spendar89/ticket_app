class Team < ActiveRecord::Base
  attr_accessible :name, :games, :url, :venue_name, :venue_address, :division, :last_5, :conference, :record
  has_many :sections
  has_many :stars
  has_many :games, :inverse_of => :team
  validates :url, :presence => true, :uniqueness => true, :on => :create
  
  def make_games
    array = []
    SeatGeek::Connection.events({:q => self[:name], :per_page => 75})['events'].each do |game_info|
      game_info["performers"].each do |team|
           array << game_info  if team["name"] == self[:name] && team["home_team"] == true
      end
    end
    array
  end  

  def get_url
    StubHub::TicketFinder.team_url(self.name)
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
    puts "setting sections for #{self[:name]}...".blue
    tickets_array = []
    self.games.find_each do |game|
      tickets_array << StubHub::TicketFinder.new(self[:name], game, 1, 5000).all_available
    end
    tickets_array.each do |all_tickets|
      all_tickets.each do |ticket|
        self.sections.create(:name => ticket[0][:section])
        puts "section created".green
      end
    end
  end
  
  def date_range?(game, date_start, date_end)
    game_date = game.date
    game_date >= converted_date(date_start) &&  game_date <= converted_date(date_end)
  end
  
  def converted_date(date)
    Date.strptime(date, "%m-%d-%Y")  
  end
  
  def filtered_games(date_start, date_end)
    total_tickets = 0
    filtered = []
    self.games.order("date").each do |game| 
      filtered << game if date_range?(game, date_start, date_end)
      total_tickets += game.number_of_tickets
    end
    {:games => filtered, :total_tickets => total_tickets}
  end
  
  def price_chart(price_data, rating_data, dates)
    LazyHighCharts::HighChart.new('graph') do |f|
        f.chart!(:backgroundColor => 'transparent')
        f.title(:style=>{:color => 'transparent'})
        f.credits!({:enabled => false})
        f.legend(:enabled => false, :floating => 'true', :y => -300, :x => 600, :itemStyle => {:fontSize => '20px'}, :layout => 'vertical')
        
        f.tooltip!(:formatter => 
          "function() {
            if (this.series.name == 'Average Ticket Price'){ 
              return 'Average Ticket Price: ' + '<b>$' + this.y + '<b>';
            }
            else{
              return 'Game Score: ' + '<b>' + this.y + '<b>';
            }
          }".js_code, :style => {:fontSize => '20px'})
        f.series(:name => 'Average Ticket Price', :type => 'line', :data => price_data, :xAxis => 0, :yAxis => 0, :lineWidth => 4, :lineColor => "#DE3F41")
        f.series(:name => 'Game Score', :type => 'line', :data => rating_data, :xAxis => 0, :yAxis => 1, :lineWidth => 4, :lineColor => "#3647CF")
        f.xAxis!([{:labels => {:style => {:fontSize => '20px', :color => "#858585"}, :y => 20, :align => "center"}, :categories => dates, :lineWidth => 0}])
        f.yAxis!([{:title => {:text => false}, :gridLineColor => 'transparent', :labels => {:enabled => false}}, 
                  {:title => {:text => false}, :gridLineColor => 'transparent', :labels => {:enabled => false}}])
    end
  end
  end