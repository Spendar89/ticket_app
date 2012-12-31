class Section < ActiveRecord::Base
  attr_accessible :average_price, :std_dev, :team_id, :name, :seat_view_url
  belongs_to :team
  validates :name, :uniqueness => {:scope => :team_id }, :on => :create
  validates :average_price, :std_dev, :presence => true, :numericality => true, :on => :update

  def tickets
    $redis.smembers "tickets_for_section:#{self[:id]}"
  end
    
  def update_std_dev
    unless number_of_tickets < 10
      prices = tickets_price_array
      length = number_of_tickets
      average = average_price
      squared = prices.map{ |price| (price - average)**2 }
      std_dev = Math.sqrt((squared.inject(0){|x, y| x + y }/length).to_f) unless length < 1
      self.update_attributes(:average_price => average, :std_dev => std_dev)
    end
  end
  
  def average_price
    100
  end
  
  def number_of_tickets
    tickets.length
  end
  
end


