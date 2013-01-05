module SearchesHelper    
  def check_overall_rating(overall_rating)
    return ["game_tickets green span12", "badge badge-success"] if overall_rating >= 65 
    return ["game_tickets yellow span12", "badge badge-warning"] if overall_rating < 65 && overall_rating >= 50
    return ["game_tickets red span12", "badge badge-important"] if overall_rating < 50
  end

  
  def game_price_chart(game_id)
    LazyHighCharts::HighChart.new('graph') do |f|
        prices_array = $redis.zrange "game:average_price_over_time:#{game_id}", 0, -1, withscores: true
        graph_data = prices_array.map{|prices| [DateTime.parse(prices[0]).to_f, prices[1].to_f]}
        f.chart!(:backgroundColor => 'transparent')
        f.title(:style=>{:color => 'transparent'})
        f.credits!({:enabled => false})
        f.legend(:enabled => false, :floating => 'true', :y => -300, :x => 600, :itemStyle => {:fontSize => '20px'}, :layout => 'vertical')
        
        f.tooltip!(:enabled => true)
        f.series(:name => 'Average Ticket Price', :type => 'line', :data => prices_array, :lineWidth => 4, :lineColor => "#DE3F41")
        f.xAxis!({:labels => {:enabled => true}, :lineWidth => 0, :categories => prices_array.map{|prices| Date.parse(prices[0]).strftime("%-m/%d")}})
        f.yAxis!({:title => {:text => false}, :gridLineColor => 'transparent', :labels => {:enabled => true}})
    end
  end

  
  def ticket_summary(game, section)
    game_id = game[:id]
    ticket = @game_data[:best_ticket]
    team = game.team
    team_id = team[:id]
    date = game[:date].strftime("%A, %B %d")
    day_of_week = date.split(',')[0]
    average_game_price = game.average_price.to_i
    min_game_price_array =  $redis.zrange "tickets_for_game_by_price:#{game_id}", 0, 0, withscores: true
    max_game_price_array =  $redis.zrange "tickets_for_game_by_price:#{game_id}", -1, -1, withscores: true
    min_game_price = min_game_price_array[0][1].to_i
    max_game_price = max_game_price_array[0][1].to_i
    number_tickets = game.number_of_tickets
    opponent_object = game.opponent_object
    opp_stars_array = opponent_object.stars
    section_name = section[:name].split(' ').map!{|word| word[0].upcase + word[1..-1]}.join(" ")
    average_section_price = section[:average_price]
    number_of_sections = $redis.zcard "sections_for_team_by_average_price:#{team_id}"
    section_rank = $redis.zrevrank "sections_for_team_by_average_price:#{team_id}", section[:id]
    ticket_price_rank = $redis.zrank "tickets_for_game_by_price:#{game_id}", ticket['stub_hub_id']
    
    # gen_stats_header = "General Stats: "
    gen_stats_0 = raw("<td><b>Tickets Available: </b></td><td>#{number_tickets}</td>")
    gen_stats_1 = raw("<td><b>Min Price: </b></td><td>$#{min_game_price}</td>")
    gen_stats_2 = raw("<td><b>Max Price: </b></td><td>$#{max_game_price}</td>")
    gen_stats_3 = raw("<td><b>Average Price: </b></td><td>$#{average_game_price}</td>")
  
    # opp_score_header = "Game Score: #{@game_data[:game_rating]}"
    game_score_0 = raw("<td><b>Opponent Name: </b></td><td>#{opponent_object[:name]}</td>")
    game_score_1 = raw("<td><b>Record: </b></td><td>#{opponent_object[:record]}</td>")
    overall_star_rating = 0
    game_score_3 = raw("<td><b>Star Players: </b></td>")
    stars_list = ""
    if opp_stars_array.length == 0
      stars_list += "<td>none</td>"
    else   
      stars_list += "<td>"
      opp_stars_array.each do |star|
        stars_list += "#{star[:name]}, "
        overall_star_rating += (star[:rating].to_f * 4)
        overall_star_rating = 100 if overall_star_rating > 100
      end 
      stars_list = stars_list[0...-2]
      stars_list += "</td>"
    end
    game_score_3 = game_score_3 + raw(stars_list)
    game_score_4 = raw("<td><b>Star Rating: </b></td><td>#{overall_star_rating.to_i}</td>")
    
    # ticket_score_header = "Seat Score: #{@game_data[:seat_rating]}"
    ticket_score_0 = raw("<td><b>Expected Ticket Price: </b></td><td>$#{average_section_price}</td>")
    ticket_score_1 = raw("<td><b>Actual Ticket Price: </b></td><td>$#{ticket['price']}</td>")
    ticket_score_2 = raw("<td><b>Section: </b></td><td>#{section_name}</td>")
    ticket_score_3 = raw("<td><b>Section Rank: </b></td><td>#{section_rank}/#{number_of_sections}</td>")
    
    
   return [gen_stats_0, gen_stats_1, gen_stats_2, gen_stats_3, 
          game_score_0, game_score_1, game_score_3, game_score_4,
          ticket_score_0, ticket_score_1, ticket_score_2, ticket_score_3]
    
  end
end
