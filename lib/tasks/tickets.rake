require 'stub_hub'

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
  task :set => :environment do   
    teams = Team.all
    Parallel.each(teams, :in_processes => 5) do |team|
      ActiveRecord::Base.connection.reconnect!
          puts "finding games for #{team.name}...".yellow
          team.games.find_each{ |game| game.destroy if game[:date] < Date.current }
          team.make_games.each{ |game_info| team.games.build.set_attributes(game_info) }
          puts "games added #{team.name}...".green
      end  
  end
end

namespace :sections do
  task :set => :environment do
    teams = Team.all
    Parallel.each(teams, :in_processes => 5) do |team|
      ActiveRecord::Base.connection.reconnect!
        team.get_sections
    end    
  end

  task :refresh => :environment do
    sections = Section.all
    Parallel.each(sections, :in_threads => 4) do |section|
      ActiveRecord::Base.connection_pool.with_connection do
        old_std_dev = section[:std_dev]
        section.update_std_dev
        new_std_dev = section[:std_dev]
        puts "old std_dev: #{old_std_dev}...new std_dev: #{new_std_dev}".green
      end
    end
  end
  
  task :update_seat_view_urls => :environment do
    begin
      Parallel.each(Section.all, :in_threads => 4) do |section|
        ActiveRecord::Base.connection_pool.with_connection do
          puts "updating section...".yellow
          section.update_seat_view_url
          puts "section updated".green
        end
      end
      rescue Exception => e
        puts "#{e}".red   
    end
  end
end
  
namespace :redis do
  task :set_teams => :environment do
      teams = Team.all
      Parallel.each(teams, :in_threads => 4) do |team| 
        ActiveRecord::Base.connection_pool.with_connection do
          team_stats = team.get_team_stats
          $redis.hmset "team:#{team[:id]}", 
            :name, team[:name], :url, team[:url], :conference, team[:conference], 
            :record, team_stats[:record], :venue_name, team[:venue_name], 
            :venue_address, team[:venue_address], :division, team[:division], 
            :last_5, team_stats[:last_5]
          $redis.sadd "teams", team[:id]
        end  
      end
  end
  
  task :set_games => :environment do
    games = Game.all
    Parallel.each(games, :in_threads => 4) do |game|
      $redis.del "games_for_team:#{game[:team_id]}" 
      $redis.del "games_for_team:#{game[:team_id]}:by_date"
      ActiveRecord::Base.connection_pool.with_connection do
        game_date = game[:date]
        id = game[:id]
        $redis.hmset "game:#{id}", 
          :date, game_date, :opponent, game[:opponent], 
          :team_id, game[:team_id]
        $redis.sadd "games_for_team:#{game[:team_id]}", id
        $redis.zadd "games_for_team:#{game[:team_id]}:by_date", game_date.to_datetime.to_i, id
        puts "game added for #{game[:id]}".green 
      end   
    end
     
  end
  
  task :set_sections => :environment do
      begin
      sections = Section.all
        Parallel.each(sections, :in_threads => 4) do |section|
          ActiveRecord::Base.connection_pool.with_connection do
            $redis.hmset "section:#{section[:id]}", :name, "#{section[:name]}", 
              :team_id, section[:team_id], :average_price, "#{section[:average_price]}", :std_dev, "#{section[:std_dev]}"
            $redis.zadd "sections_for_team_by_name:#{section[:team_id]}", section[:id], section[:name]
            $redis.zadd "sections_for_team_by_average_price:#{section[:team_id]}", section[:average_price], section[:id]
            puts "section #{section[:id]} update".green
          end
        end
      rescue Timeout::Error => e
        puts "Timeout Error: #{e}".red
      end
  end
  
  task :clear_sections => :environment do
    sections = Section.all
    Parallel.each(sections, :in_threads => 30) do |section|
       $redis.del "tickets_for_section_by_price:#{section[:id].to_f}"
    end
  end
  
  task :update_tickets => :environment do
    begin
    start_time = Time.now
    games = Game.all
    Parallel.each(games, :in_threads => 30) do |game|
        game_id = game[:id]
        team_id = game[:team_id]
        $redis.del "tickets_for_game_by_seat_value:#{game_id}"
        $redis.del "tickets_for_game_by_price:#{game_id}"
        Ticket.update_redis(team_id, game_id)
        game_average_price = Game.average_price(game_id)
        $redis.zadd "games:average_price", game_average_price, game_id
        $redis.zadd "game:average_price_over_time:#{game_id}", game_average_price, DateTime.current
    end
    rescue Timeout::Error => e
      puts "Error: #{e}"
    end
    puts "completed in #{((Time.now - start_time)/60).to_f} minutes" 
  end
  
  task :update_tickets_for_team => :environment  do
    team = Team.find_by_name(ENV['spec_team'])
    games = team.games
    Parallel.each(games, :in_threads => 15) do |game|
        game_id = game[:id]
        team_id = game[:team_id]
        $redis.del "tickets_for_game_by_seat_value:#{game_id}"
        $redis.del "tickets_for_game_by_price:#{game_id}"
        Ticket.update_redis(team_id, game_id)
        game_average_price = Game.average_price(game_id)
        $redis.zadd "games:average_price", game_average_price, game_id
        $redis.zadd "game:average_price_over_time:#{game_id}", game_average_price, DateTime.current
    end
    puts "Tickets updated".green
  end
  
  
end