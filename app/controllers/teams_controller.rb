class TeamsController < ApplicationController
  def create
      @team = Team.new(:name => params[:search][:team])
      @team.url = @team.get_url
      @team.save
      @team.make_games.each{ |game_info| @team.games.new.set_attributes(game_info) }
      @team.games.each{ |game| game.set_average_price }
      @team.games.each{ |game| game.determine_relatives }
      @team.update_attributes(:section_averages => @team.get_section_averages)
      @team.update_attributes(:section_standard_deviations => @team.get_section_standard_deviations)
      @team.get_seat_views
      redirect_to searches_path(:search => params[:search])
  end

end
