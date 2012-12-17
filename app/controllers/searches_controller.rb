class SearchesController < ApplicationController
  
  def new
    @search = Search.new
  end
  
  def show
    @search = Search.new
    @team = Team.find_by_name(params[:search][:team])
    @price_min = 1
    @total_tickets = 0
    @team.games.find_each do |game| 
      @total_tickets += game.tickets.length 
    end
    @price_max = 5000
    @games = @team.games
    respond_to do |format|
      format.js
    end   
  end

  def update
      date_start = params[:search][:date_start]
      date_end = params[:search][:date_end]
      @team = Team.find_by_name(params[:search][:team])
      @price_min = params[:search][:price_min].to_i
      @price_max = params[:search][:price_max].to_i
      @games = [] 
      @total_tickets = 0
      @team.games.find_each do |game| 
        @games << game if Date.strptime(game[:date], "%m-%d-%Y") >= Date.strptime(date_start, "%m-%d-%Y") && Date.strptime(game[:date], "%m-%d-%Y") <= Date.strptime(date_end, "%m-%d-%Y")
        @total_tickets += game.tickets.length 
      end
      respond_to do |format|
        format.js
      end
  end

end
