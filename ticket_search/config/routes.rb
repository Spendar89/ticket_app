TicketSearch::Application.routes.draw do
  resources :teams do
    resources :games
  end

  root :to => 'teams#search'


end
