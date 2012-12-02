require_relative 'tickets'
require_relative 'oracle_arena_sections'

class Arena
  def initialize(tickets, section_hash)
    @tickets = tickets
    @section_hash = section_hash
  end

  def find_seat_value(section, row)
      section_value = section.to_i
      row_value = ""
      case row_value
        when row == "AA"; -5
        when row == "A1"; 1
        when row == "A2"; 2
        when row == "A3"; 3
        when row == "A4"; 4
        when row == "A5"; 5
        else
          row_value = row.to_i
      end
      100-(section_value + row_value)
  end

  def converted_seats
    converted_seats = []
    @tickets.best_all_available.each do |seat|
      converted_seats << [{:ticket_id => seat[0][:ticket_id], :price => seat[0][:price],  :value => find_seat_value(@section_hash[seat[0][:section].to_s], seat[0][:row])}]
    end
    converted_seats
  end

  def value_index
    values = {}
    converted_seats.each do |seat|
      values.merge!(seat[0][:ticket_id] => {:price => seat[0][:price], :index => seat[0][:value].to_f/seat[0][:price].to_f})
    end
    values
  end

  def sorted_tickets
    test = {}
    value_index.each_pair do |seat_id, values|
        test.merge!(seat_id => values[:index])
    end
    test.sort_by{|key, value| value}
  end

  def best_ticket
    best = sorted_tickets.last
    @tickets.best_all_available.each do |seat|
        if seat[0][:ticket_id] == best[0]
          return seat
        end
    end
  end


end
tickets = Tickets.new("Golden State Warriors", 100, 200)
oracle = Arena.new(tickets, $oracle_arena_hash)
puts oracle.best_ticket