class Section < ActiveRecord::Base
  attr_accessible :average_price, :std_dev, :team_id, :name, :seat_view_url
  belongs_to :team
  has_many :tickets, :inverse_of => :section
  validates :name, :uniqueness => {:scope => :team_id }
  validates :average_price, :std_dev, :presence => true, :numericality => true, :on => :update

  def update_std_dev
    average = self.tickets.average(:price).to_f
    squared = self.tickets.pluck(:price).collect{ |price| (price - average)**2 }
    std_dev = Math.sqrt((squared.inject(0){|x, y| x + y }/self.tickets.length).to_f).to_f unless self.tickets.length < 1
    self.update_attributes(:average_price => average, :std_dev => std_dev)
  end
end


