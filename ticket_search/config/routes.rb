TicketSearch::Application.routes.draw do
  resources :searches, :only => [:new, :show]
  get '/searches', :to => 'searches#show'
  
  resources :teams do
    collection do
      get :get_games
    end
    resources :games
  end

  root :to => 'searches#new'


end
