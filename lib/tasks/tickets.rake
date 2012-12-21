namespace :teams do
  task :set => :environment do
    nba_teams = ["Atlanta Hawks", "Boston Celtics", "Charlotte Bobcats", 
                "Chicago Bulls", "Cleveland Cavaliers", "Dallas Mavericks", 
                "Denver Nuggets", "Detroit Pistons", "Golden State Warriors", 
                "Houston Rockets", "Indiana Pacers", "Los Angeles Clippers", 
                "Los Angeles Lakers", "Memphis Grizzlies", "Miami Heat", 
                "Milwaukee Bucks", "Minnesota Timberwolves", "Brooklyn Nets", 
                "New Orleans Hornets", "New York Knicks", "Oklahoma City Thunder", 
                "Orlando Magic", "Philadelphia 76ers", "Phoenix Suns", 
                "Portland Trail Blazers", "Sacramento Kings", "San Antonio Spurs", 
                "Toronto Raptors", "Utah Jazz", "Washington Wizards"] 
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