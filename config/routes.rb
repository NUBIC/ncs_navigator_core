NcsNavigatorCore::Application.routes.draw do
  resources :dwelling_units
  resources :household_units
  resources :people do
    member do 
      get :events
      get :start_instrument
    end
  end
  resources :participants
  
  root :to => "welcome#index"
end
