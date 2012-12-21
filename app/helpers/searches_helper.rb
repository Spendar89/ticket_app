module SearchesHelper
  def seat_view_url(venue, section)
    url = open("http://api.avf.ms/venue.php?jsoncallback=?key=33970eb4232b8bd273dd548da701abd2&venue=#{URI.escape(venue)}&section=#{section}").read
    hash = JSON.parse("{#{url.scan(/"image":"\w+-\d+.jpg"/)[0]}}")
    return "http://aviewfrommyseat.com/wallpaper/#{hash['image']}" if !hash['image'].nil?
    return false
  end
  
  def check_overall_rating(overall_rating)
    return ["game_tickets green span3", "badge badge-success"] if overall_rating >= 65 
    return ["game_tickets yellow span3", "badge badge-warning"] if overall_rating < 65 && overall_rating >= 50
    return ["game_tickets red span3", "badge badge-warning"] if overall_rating < 50
  end
  
  def ticket_summary(game_data)
    ticket = game_data[:best_ticket]
    team = ticket.section.team
    game = ticket.game
    date = Date.strptime(game[:date], "%m-%d-%Y").strftime("%A, %B %d")
    day_of_week = date.split(',')[0]
    average_game_price = game.tickets.average(:price)
    min_game_price = game.tickets.minimum(:price)
    number_tickets = game.tickets.count
    average_section_price = ticket.section.tickets.average(:price)
    part_1 = "The #{team.record} #{team[:name]} take on the #{game[:opponent]} at 
            #{game[:venue]} on #{date}.  
            The #{team[:name].split(' ')[-1]} are #{team.last_5} over their last five games "
    if team.last_5[0].to_i >= 3 
      part_2 = "and they look to continue their winning ways against the #{game[:opponent].split(' ')[-1]}.  " 
    else
      part_2 = "so they hope to turn it around against the #{game[:opponent].split(' ')[-1]}.  "
    end
    part_3 = "The average ticket for this matchup costs $#{average_game_price.to_i}, 
              yet tickets can be found for as low as $#{min_game_price}. This ticket was reccomended 
              for a number of reasons.  On average, #{team[:name].split(' ')[-1]} tickets in this section cost 
              $#{average_section_price.to_i}.  "
    if average_section_price > ticket[:price]
      part_4 = "That's #{(average_section_price/ticket[:price]).round(1)} times
                more expensive than this ticket, "
      if game_data[:seat_rating] >= 66
        part_5 = "which makes it an especially great deal.  "
      elsif game_data[:seat_rating] >= 50 && game_data[:seat_rating] < 66
        part_5 = "which makes it a fairly good deal.  "
      end   
      if game[:relative_popularity] < 50
          part_6 = "It is worth noting that this game is relatively less popular than other games on the schedule, "
          if ["Friday", "Saturday", "Sunday"].include?(day_of_week)
            part_7 = "despite it being played on a weekend, so ticket prices are lower across the board."
          else
            part_7 = "in part because it is being played on a weekday, so ticket prices are lower across the board."
          end
      else
        part_6 = "This game is relatively more popular than other games on the schedule, "
        if ["Friday", "Saturday", "Sunday"].include?(day_of_week)
          part_7 = "in part because it is being played on a weekend, so ticket prices are higher across the board."
        else
          part_7 = "despite it being played on a weekday."
        end     
      end
      
    else
       part_4 = "That is #{(average_section_price/ticket[:price]).round(1)} times
                 less expensive than this ticket, but unforunately less expensive tickets are
                 no longer available."
      part_5 = ""
      part_6 = ""
      part_7 = ""
    end
    return part_1 + part_2 + part_3 + part_4  + part_5 + part_6 + part_7
  end
end
