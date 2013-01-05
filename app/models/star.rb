class Star < ActiveRecord::Base
  attr_accessible :name, :rating, :team_id
  belongs_to :team
  
  def self.ordered_stars
    ["Tyreke Evens", "OJ Mayo", "Kenneth Faried", "Damian Lillard", "Danilo Galinari ", 
      "Ray Allen", "Demarcus Cousins", "David Lee", "John Wall", "Joakim Noah", "Brook Lopez", 
      "Monta Ellis", "Brandon Jennings", "Andre Iguadala ", "LaMarcus Aldridge", "Amare Stoudemire", 
      "Manu Ginobili", "Marc Gasol", "Zach Randolph", "Tony Parker", "Anthony Davis", "Stephen Curry", 
      "Tyson Chandler", "Tim Duncan", "Rudy Gay", "Joe Johnson", "Kyrie Irving", "Chris Bosh", "James Harden", 
      "Josh Smith", "Paul Pierce", "Ricky Rubio", "Kevin Garnet", "Pau Gasol", "Dirk Nowitzki", "Jeremy Lin", 
      "Deron Williams", "Kevin Love", "Dwight Howard", "Rajon Rondo", "Russell Westbrook", "Blake Griffin", 
      "Dwayne Wade", "Steve Nash", "Derrick Rose", "Carmelo Anthony", "Chris Paul", "Kevin Durant", "Kobe Bryant", 
      "LeBron James"] 
  end
  
  def self.ordered_teams
     ["Sacramento Kings", "Memphis Grizzlies", "Denver Nuggets", "Portland Trail Blazers", "Denver Nuggets", 
       "Miami Heat", "Sacramento Kings", "Golden State Warriors", "Washington Wizards", 
       "Chicago Bulls", "Brooklyn Nets", "Milwaukee Bucks", "Milwaukee Bucks", "Denver Nuggets", "Portland Trail Blazers", 
       "New York Knicks", "San Antonio Spurs", "Memphis Grizzlies", "Memphis Grizzlies", "San Antonio Spurs", "New Orleans Hornets", 
       "Golden State Warriors", "New York Knicks", "San Antonio Spurs", "Memphis Grizzlies", "Brooklyn Nets", "Cleveland Cavaliers", 
       "Miami Heat", "Houston Rockets", "Atlanta Hawks", "Boston Celtics", "Minnesota Timberwolves", "Boston Celtics", "Los Angeles Lakers", 
       "Dallas Mavericks", "Houston Rockets", "Brooklyn Nets", "Minnesota Timberwolves", "Los Angeles Lakers", "Boston Celtics", 
       "Oklahoma City Thunder", "Los Angeles Clippers", "Miami Heat", "Los Angeles Lakers", "Chicago Bulls", "New York Knicks", 
       "Los Angeles Clippers", "Oklahoma City Thunder", "Los Angeles Lakers", "Miami Heat"] 
  end
  
  def self.set
    self.ordered_stars.each_with_index do |star_name, i|
      team_name = self.ordered_teams[i]
      Star.create(:name => star_name, :rating => (i/5.0).to_f, :team_id => Team.find_by_name(team_name).id)
    end
  end
  
  def self.destroy_all
    Star.find_each {|star| star.destroy}
  end
  
end