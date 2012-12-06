TicketSearch::Application.routes.draw do
  resources :teams do
    collection do
      get :get_games
    end
    resources :games
  end

  root :to => 'teams#search'


end
