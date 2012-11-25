require_relative 'seat_geek.rb'





tickets = Tickets.new('Golden State Warriors')

oracle = Arena.new(tickets, $oracle_arena_hash)

#puts oracle.value_index

#puts tickets.all_available

#puts oracle.get_best_ticket(150)

#puts tickets.all_available.length

#puts tickets.all_available.inspect
#puts OracleArena.new.calculate_seat(@section_hash['14'], 12)

#
# ticket_form = page.form('form1')
# price = ticket_form.field(:name => 'ucTicketList$ddlMinPrice')
# price.option_with(:value => /500/).select
# ticket_form.submit
# #
# page.search("tr.inventoryRow").each do |node|
#   puts node
# end


# page = agent.submit(select)
#pp page
#pp select
server = Selenium::Server.new("selenium-server-standalone-2.0b1.jar", :background => true)
server.start

capabilities = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)

browser = Watir::Browser.new(:remote, :url => "http://127.0.0.1:4444/wd/hub",
    :desired_capabilities => capabilities)


browser.goto'http://www.ticketsnow.com/NBA/InventoryBrowse/Golden-State-Warriors-Tickets-at-ORACLE-Arena-in-Oakland-11-29-2012?PID=1310047'
#browser.goto 'http://www.ticketsnow.com/NBA/InventoryBrowse/Golden-State-Warriors-Tickets-at-ORACLE-Arena-in-Oakland-11-29-2012?PID=1310047'
#puts browser.select_list(:name => 'ucTicketList$ddlMinPrice').options
browser.select_list(:name => 'ucTicketList$ddlMinPrice').select '$100'

browser.element(:css => ".inventoryRow").each do |item|
  puts item
end

server.stop




# puts TeamGames.new('Golden State Warriors').home_games[0].opponent
# puts TeamGames.new('Golden State Warriors').home_games[0].relative_price


#puts TeamGames.new('Golden State Warriors').home_price_standard_deviation

#puts TeamGames.new('Los Angeles Lakers').home_games[0].inspect

#puts TeamGames.new('Los Angeles Lakers').home_games