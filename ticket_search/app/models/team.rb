class Team < ActiveRecord::Base
  attr_accessor :best_game_id
  attr_accessible :name
end
