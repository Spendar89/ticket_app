class SearchesController < ApplicationController
  include ActionView::Helpers::JavaScriptHelper
  
  def new
    @search = Search.new
  end
  
  def show
    @search = Search.new
    @team = Team.find_by_name(params[:search][:team])
    @price_min = 1
    @total_tickets = 0
    @team.games.find_each { |game| @total_tickets += game.tickets.length }
    @price_max = 5000
    @games = @team.games
    @number = 1
    @price_data = []
    @rating_data = []
    @scatter_data = []
    @games.each do |game| 
      @price_data << {y: game[:average_price].to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
      @rating_data << {y: game[:relative_popularity].to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
    end
    @line = @team.price_chart(@price_data, @rating_data)
    respond_to do |format|
      format.html
    end   
  end

  def update
      @date_start = params[:search][:date_start]
      @date_end = params[:search][:date_end]   
      @price_min = params[:search][:price_min].to_i
      @price_max = params[:search][:price_max].to_i      
      @team = Team.find_by_name(params[:search][:team])
      @number = 1
      filtered_games = @team.filtered_games(@date_start, @date_end)
      @games = filtered_games[:games]
      @total_tickets = filtered_games[:total_tickets] 
      respond_to do |format|
        format.js
      end
  end

end
