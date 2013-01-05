module SearchesHelper    
  def check_overall_rating(overall_rating)
    return ["game_tickets green span12", "badge badge-success"] if overall_rating >= 65 
    return ["game_tickets yellow span12", "badge badge-warning"] if overall_rating < 65 && overall_rating >= 50
    return ["game_tickets red span12", "badge badge-important"] if overall_rating < 50
  end

  
  def game_price_chart(game_id)
    LazyHighCharts::HighChart.new('graph') do |f|
        prices_array = $redis.zrange "game:average_price_over_time:#{game_id}", 0, -1, withscores: true
        prices_array.map!{|prices| [prices[0].to_i, prices[1].to_f]}
        f.chart!(:backgroundColor => 'transparent')
        f.title(:style=>{:color => 'transparent'})
        f.credits!({:enabled => false})
        f.legend(:enabled => false, :floating => 'true', :y => -300, :x => 600, :itemStyle => {:fontSize => '20px'}, :layout => 'vertical')
        
        # f.tooltip!(:formatter => 
        #   "function() {
        #     if (this.series.name == 'Average Ticket Price'){ 
        #       return 'Average Ticket Price: ' + '<b>$' + this.y + '<b>';
        #     }
        #     else{
        #       return 'Game Score: ' + '<b>' + this.y + '<b>';
        #     }
        #   }".js_code, :style => {:fontSize => '20px'})
        f.series(:name => 'Average Ticket Price', :type => 'line', :data => prices_array, :lineWidth => 4, :lineColor => "#DE3F41")
        f.xAxis!({:labels => {:enabled => false}, :lineWidth => 0})
        f.yAxis!({:title => {:text => false}, :gridLineColor => 'transparent', :labels => {:enabled => false}})
    end
  end

  
  def ticket_summary(game, section)
    game_id = game[:id]
    ticket = @game_data[:best_ticket]
    team = game.team
    team_id = team[:id]
    date = game[:date].strftime("%A, %B %d")
    day_of_week = date.split(',')[0]
    average_game_price = game.average_price
    min_game_price_array =  $redis.zrange "tickets_for_game_by_price:#{game_id}", 0, 0, withscores: true
    max_game_price_array =  $redis.zrange "tickets_for_game_by_price:#{game_id}", -1, -1, withscores: true
    min_game_price = min_game_price_array[0][1].to_i
    max_game_price = max_game_price_array[0][1].to_i
    number_tickets = game.number_of_tickets
    opponent_object = game.opponent_object
    opp_stars_array = opponent_object.stars
    average_section_price = section[:average_price]
    number_of_sections = $redis.zcard "sections_for_team_by_average_price:#{section[:team_id]}"
    section_rank = $redis.zrevrank "sections_for_team_by_average_price:#{section[:team_id]}", section[:id]
    ticket_price_rank = $redis.zrank "tickets_for_game_by_price:#{game_id}", ticket['stub_hub_id']
    
    gen_stats_header = "General Stats: "
    gen_stats_1 = "Number of Tickets Available: #{number_tickets}"
    gen_stats_2 = "Min Price: #{min_game_price}"
    gen_stats_3 = "Max Price: #{max_game_price}"
    gen_stats_4 = "Average Price: #{average_game_price}"
  
    opp_score_header = "Game Score: #{@game_data[:game_rating]}"
    opp_name_expl = "Opponent Name: #{opponent_object[:name]}"
    opp_record_expl = "Record: #{opponent_object[:record]}"
    opp_last_5_expl = "Last 5 Games: #{opponent_object[:last_5]}"
    opp_stars_expl_1 = "Star Players: "
    opp_stars_expl_1 += "none" if opp_stars_array.length == 0
    overall_star_rating = 0
    opp_stars_array.each do |star|
      opp_stars_expl_1 += "#{star[:name]}, "
      overall_star_rating += (star[:rating].to_f * 4)
      overall_star_rating = 100 if overall_star_rating > 100
    end
    opp_stars_expl_1 = opp_stars_expl_1[0...-2]
    opp_stars_expl_2 = "Overall Star Quality: #{overall_star_rating.to_i} "
    
    ticket_score_header = "Seat Score: #{@game_data[:seat]}"
    ticket_score_1 = "Ticket Price: #{ticket['price']}"
    ticket_score_2 = "Ticket Section Average Price: #{average_section_price}"
    ticket_score_3 = "Section Rank(by price): #{section_rank}/#{number_of_sections}"
    
    
   return [gen_stats_1 + gen_stats_2 + gen_stats_3 + gen_stats_4, opp_record_expl + opp_last_5_expl + opp_stars_expl_1 + opp_stars_expl_2, ticket_score_1 + ticket_score_2 + ticket_score_3]
    
  end
end
