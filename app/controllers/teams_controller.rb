class TeamsController < ApplicationController
  def create
      @team = Team.new(:name => params[:search][:team])
      @team.url = @team.get_url
      @team.save
      @team.make_games.each{ |game_info| @team.games.new.set_attributes(game_info) }
      @team.games.each do |game|
        game.determine_relatives
        game.refresh_tickets
      end
      @team.get_seat_views
      @team.set_attributes
      @team.get_sections
      redirect_to searches_path(:search => params[:search])
  end

end
