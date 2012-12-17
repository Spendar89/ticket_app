TicketSearch::Application.routes.draw do
  match "/teams" => "teams#create"
  put "/searches" => "searches#update"
  resources :teams do
    resources :games
  end
  resources :searches, :only => [:new, :show, :update]
  get '/searches', :to => 'searches#show'



  root :to => 'searches#new'


end
