require 'open-uri'
class Section < ActiveRecord::Base
  attr_accessible :average_price, :std_dev, :team_id, :name, :seat_view_url
  belongs_to :team
  validates :name, :uniqueness => {:scope => :team_id }, :on => :create
  validates :average_price, :std_dev, :presence => true, :numericality => true, :on => :update

  def tickets
    $redis.zrange "tickets_for_section:#{self[:id]}:by_price", 0, -1
  end
    
  def update_std_dev
    unless number_of_tickets < 2
      average = average_price
      squared = prices_array.map{ |price| (price - average)**2 }
      std_dev = Math.sqrt((squared.inject(0){|x, y| x + y }/number_of_tickets).to_f)
      self.update_attributes(:average_price => average, :std_dev => std_dev)
    end
  end
    
  def seat_view_url
    section_name = self[:name].scan(/\d{1,3}/)[-1]
    venue_name = self.team[:venue_name]
    url = open("http://api.avf.ms/venue.php?jsoncallback=?key=33970eb4232b8bd273dd548da701abd2&venue=#{URI.escape(venue_name)}&section=#{section_name}").read
    hash = JSON.parse("{#{url.scan(/"image":"\w+-\d+.jpg"/)[0]}}")
    return "http://aviewfrommyseat.com/wallpaper/#{hash['image']}" if !hash['image'].nil?
    return false
  end
  
  def update_seat_view_url
    self.update_attributes(:seat_view_url => seat_view_url)
  end
  
  def average_price
    sum = prices_array.inject(0){|x, y| x + y} 
    sum/number_of_tickets
  end
  
  def prices_array
    tickets.map do |ticket| 
      ticket_hash = $redis.hgetall "ticket:#{ticket}"
      ticket_hash["price"].to_i
    end  
  end
  
  def number_of_tickets
   $redis.zcard "tickets_for_section:#{self[:id]}:by_price"
  end
  
end


