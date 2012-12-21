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
    @team.games.find_each do |game| 
      @total_tickets += game.tickets.length 
    end
    @price_max = 5000
    @games = @team.games
    @price_data = []
    @rating_data = []
    @games.each do |game, i| 
      @price_data << {y: game.tickets.average(:price).to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
      @rating_data << {y: game[:relative_popularity].to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
    end
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart!({:defaultSeriesType => "line", :backgroundColor => 'transparent', :spacingLeft => 15})
      f.title!({:align => 'left', :text => "Average Game Prices", :style => {fontSize: '25px', color: 'transparent', fontWeight: 'bold'}})
      f.credits!({:enabled => false})
      f.options[:legend][:enabled] = false
      f.series(:name => 'average ticket price', :data=> @price_data)
      f.series(:name => 'game score', :data => @rating_data)
      f.xAxis!({:labels => {:enabled => false }})
      # f.options[:yAxis][:labels][:enabled] = false
      f.yAxis!({:gridLineColor => 'transparent', :labels => {:enabled => false}})
      f.plotOptions!({:line => {:lineWidth => 6.0, :color => '#D76E34'}})
      
      # plotBackgroundImage
    end  
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
      @price_data = []
      @price_labels = []
      @games.each do |game, i| 
        @price_data << {y: game.tickets.average(:price).to_i, marker: {symbol: "url(assets/small_icons/#{game[:opponent].split(' ')[-1]}_40x40.png)"}}
        @price_labels << Date.strptime(game[:date],"%m-%d-%Y").strftime("%-m/%-d")
      end
      @h = LazyHighCharts::HighChart.new('graph') do |f|
        f.chart!({:defaultSeriesType => "line", :backgroundColor => 'transparent', :spacingLeft => 15})
        f.title!({:align => 'left', :text => "Average Game Prices", :style => {fontSize: '25px', color: 'transparent', fontWeight: 'bold'}})
        f.credits!({:enabled => false})
        f.options[:legend][:enabled] = false
        f.series(:data=> @price_data)
        f.xAxis!({:labels => {:enabled => false }})
        # f.options[:yAxis][:labels][:enabled] = false
        f.yAxis!({:gridLineColor => 'transparent', :labels => {:enabled => false}})
        f.plotOptions!({:line => {:lineWidth => 6.0, :color => '#D76E34'}})
      end
      respond_to do |format|
        format.js
      end
  end

end
