require 'stub_hub'

class HardWorker
  include Sidekiq::Worker

  def perform(game_id, team_id)
    $redis.del "tickets_for_game_by_seat_value:#{game_id}"
    $redis.del "tickets_for_game_by_price:#{game_id}"
    StubHub::TicketFinder.redis_tickets(team_id.to_i, game_id.to_i)
    $redis.zadd "games:average_price", Game.average_price(game_id), game_id
  end
  
  def self.update
    start_time = Time.now
    teams = $redis.smembers "teams"
    teams.each do |team_id|
      games = $redis.smembers "games_for_team:#{team_id}"
      games.each { |game_id| perform_async(game_id, team_id) }
    end
    puts "completed in #{((Time.now - start_time)/60).to_f} minutes"
  end
  
end