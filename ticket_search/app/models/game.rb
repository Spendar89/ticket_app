class Game < ActiveRecord::Base
  attr_accessible :date, :opponent_id, :team_id
end
