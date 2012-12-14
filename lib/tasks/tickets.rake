namespace :teams do
  task :set => :environment do
    nba_teams = ["Los Angeles Lakers", "Golden State Warriors", "New York Knicks"]
    nba_teams.each do |team_name|
      team = Team.new(:name => team_name)
      team.url = team.get_url
      team.save
    end
  end
end

namespace :games do
  task :refresh => :environment do
    Team.all.each do |team|
      team.games.each{|game| game.destroy}
      team.make_games.each{ |game_info| team.games.new.set_attributes(game_info) }
    end
  end
end

namespace :sections do
  task :set => :environment do
    Team.all.each{|team| team.get_sections}
  end
  task :refresh => :environment do
     Team.all.each do |team|
       team.sections.each{|section| section.update_std_dev}
     end
  end
end

namespace :tickets do
  task :refresh => :environment do
    Game.all.each do |game|
      game.refresh_tickets
      game.destroy_outliers
    end
  end
end