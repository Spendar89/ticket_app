class TeamsController < ApplicationController

  def search
    @team = Team.new
  end

  def create
    @team = Team.find_by_name(params[:team][:name])
    @@min = params[:min_price]
    @@max = params[:max_price]
    if @team.nil?
      @team = Team.new(params[:team])
      @team.best_game_id = TicketHelper::Tickets.new(@team.name).best_game_id
      @team.save
    end
    redirect_to @team
  end

  def show
    @team = Team.find(params[:id])
    @best_ticket = TicketHelper::Tickets.new(@team.name, @team.best_game_id.to_s, @@min.to_i, @@max.to_i).best_ticket
  end


end
