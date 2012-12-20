namespace :teams do
  task :set => :environment do
    nba_teams = ["Los Angeles Lakers", "Golden State Warriors", "New York Knicks"]
    nba_teams.each do |team_name|
      team = Team.new(:name => team_name)
      team.url = team.get_url
      team.save
      team.set_attributes
    end
  end
end

namespace :games do
  task :refresh => :environment do
    Team.all.each do |team|
      puts "finding games for #{team.name}...".blue
      team.make_games.each{ |game_info| team.games.new.set_attributes(game_info)} 
      team.games.find_each{ |game| game.destroy if Date.strptime(game[:date], '%m-%d-%Y') < Date.current }
      team.set_pop_std_dev
      puts "determining_relatives....".yellow
      team.games.each{ |game| game.determine_relatives }
    end
  end
end

namespace :sections do
  task :set => :environment do
    Team.find_each{|team| team.get_sections}
  end
end

namespace :tickets do
  task :refresh => :environment do
    Game.all.each do |game|
      game.refresh_tickets
      game.destroy_outliers
      game.destroy if game.tickets.length < 100 
    end
    Team.all.each do |team| 
      team.sections.each do |section| 
        section.update_std_dev
      end
    end
  end
end

namespace :app do
  task :restart => :environment do
    Rake::Task['db:reset'].invoke
    Rake::Task['teams:set'].invoke
    Rake::Task['games:refresh'].invoke
    Rake::Task['sections:set'].invoke
    Rake::Task['tickets:refresh'].invoke
    Rake::Task['tickets:refresh'].invoke
  end
end