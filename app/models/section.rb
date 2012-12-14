class Section < ActiveRecord::Base
  attr_accessible :average_price, :std_dev, :team_id, :name
  belongs_to :team
  has_many :tickets, :inverse_of => :section
  validates :name, :uniqueness => {:scope => :team_id }

  def update_std_dev
    average = self.tickets.average(:price)
    squared = self.tickets.pluck(:price).collect{ |price| (price - average)**2 }
    std_dev = Math.sqrt(squared.inject(0){|x, y| x + y }/self.tickets.length).to_i unless self.tickets.length < 1
    self.update_attributes(:average_price => average, :std_dev => std_dev)
  end
end


