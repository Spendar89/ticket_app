class SearchesController < ApplicationController
  def new
    @search = Search.new
  end
  
  def token_input
    @teams = Team.where("teams.name LIKE ?", "%#{params[:q].split(' ').map{|word| word[0].upcase + word[1..-1]}.join(' ')}%" )
    respond_to do |format|
      format.json { render :json => @teams.collect{ |team| {:id => team[:id], :name => team[:name] }}.to_json }
    end
  end
  
  def show
    if params[:search][:team].empty?
      redirect_to :back
      flash[:error] = "Sorry, we couldn't find that team..."
      return
    end
    @search = Search.new
    @team = Team.find(params[:search][:team])  
    @price_min = 1
    @total_tickets = 0
    @games = []
    @team.games.order("date").limit(8).each{|game| @games << game if game.number_of_tickets > 5 }
    @price_max = 5000  
    @number = 1
    price_data = []
    dates = []
    rating_data = []
    @games.each do |game|
        dates << game[:date].strftime("%b %-d")    
        price_data << {y: game.average_price.to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
        rating_data << { y: game[:game_rating].to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
    end
    @line = @team.price_chart(price_data, rating_data, dates)
    respond_to do |format|
      format.html
    end   
  end

  def update
      @date_start = params[:search][:date_start] == "" ? Date.current.strftime("%m-%d-%Y") : params[:search][:date_start]
      @date_end = params[:search][:date_end] == "" ? (Date.current + 30).strftime("%m-%d-%Y") : params[:search][:date_end]
      @price_min = params[:search][:price_min].to_i
      @price_max = params[:search][:price_max].to_i      
      @team = Team.find_by_name(params[:search][:team])
      @number = 1
      filtered_games = @team.filtered_games(@date_start, @date_end)
      @games = filtered_games[:games]
      @total_tickets = filtered_games[:total_tickets]
      price_data = []
      dates = []
      rating_data = []
      @games.each do |game|
        total_tickets = game.number_of_tickets
        if total_tickets < 3 
          @games.delete(game)
        else
          dates << game[:date].strftime("%b %-d")    
          price_data << {y: game.average_price.to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
          rating_data << { y: game[:game_rating].to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
        end
      end
      @line = @team.price_chart(price_data, rating_data, dates) 
      respond_to do |format|
        format.js
      end
  end

end
