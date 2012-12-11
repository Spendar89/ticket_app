TicketSearch::Application.routes.draw do
  match "/teams" => "teams#create"
  resources :teams do
    resources :games
  end

  resources :searches, :only => [:new, :show]
  get '/searches', :to => 'searches#show'


  root :to => 'searches#new'


end
