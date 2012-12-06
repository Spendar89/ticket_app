class TeamsController < ApplicationController
  def search
    @team = Team.new
  end

  def create
    @team = Team.new(params[:team])
    @team.url = @team.get_url
    @team.save
    @team.make_games.each{ |game_info| @team.games.new.set_attributes(game_info) }
    @team.games.each{ |game| game.determine_relatives }
    redirect_to @team
  end

  def show
    @team = Team.find(params[:id])
    @games = @team.games
  end

    # @best_ticket = TicketHelper::Tickets.new(@team.name, @team.best_game_id.to_s, @@min.to_i, @@max.to_i).best_ticket
    # @team.all_games.each do |game|
    #   game.average_popularity = game.popularity
    #   game.average_price = game.average_price
    #   game.save
    # end



end
