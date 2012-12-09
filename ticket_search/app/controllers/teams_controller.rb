class TeamsController < ApplicationController
  def create
      @team = Team.new(:name => params[:search][:team])
      @team.url = @team.get_url
      @team.save
      @team.make_games.each{ |game_info| @team.games.new.set_attributes(game_info) }
      @team.games.each{ |game| game.determine_relatives }
      redirect_to searches_path(:search => params[:search])
  end

end
