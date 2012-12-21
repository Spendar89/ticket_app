class Star < ActiveRecord::Base
  attr_accessible :name, :rating, :team_id
  belongs_to :team
end
