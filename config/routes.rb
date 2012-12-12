TicketSearch::Application.routes.draw do
  match "/teams" => "teams#create"

  resources :teams do
    resources :games
  end
  resources :searches, :only => [:new, :show] do
    collection do
      get 'seat_view'
    end
  end
  get '/searches', :to => 'searches#show'



  root :to => 'searches#new'


end
