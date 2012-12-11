class SearchesController < ApplicationController
  def new
    @search = Search.new
  end

  def show
    if Team.find_by_name(params[:search][:team]).nil?
      redirect_to teams_path(:search => params[:search])
    else
      @date_start = params[:search][:date_start]
      @date_end = params[:search][:date_end]
      @team = Team.find_by_name(params[:search][:team])
      @games = []
      @price_min = params[:search][:price_min].to_i
      @price_max = params[:search][:price_max].to_i
      @team.games.each { |game| @games << game if game[:date] >= @date_start && game[:date] <= @date_end }
    end
  end

end
