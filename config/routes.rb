TicketSearch::Application.routes.draw do
  match "/teams" => "teams#create"
  put "/searches" => "searches#update"
  resources :teams do
    resources :games
  end
  resources :searches, :only => [:new, :show, :update]
  get '/token_input', :to => "searches#token_input"
  get '/searches', :to => 'searches#show'
  match "/tickets/next", :to => 'tickets#next'
  root :to => 'searches#new'


end
