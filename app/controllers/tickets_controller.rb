class TicketsController < ApplicationController
  def next
    @game = Game.find(params[:game])
    @price_min = params[:price_min].to_i
    @price_max = params[:price_max].to_i
    @next = params[:next]
    @number = params[:number].to_i + 1
    @game_data = @game.view_game_data(@price_min, @price_max , @number)  
    respond_to do |format|
      format.js
    end
  end
end
