class TeamsController < ApplicationController
  def index
    @search = Search.new
  end
end
