NcsNavigatorCore::Application.routes.draw do
  resources :dwelling_units
  resources :household_units
  resources :people do
    member do 
      get :events
    end
  end
  resources :participants
  
  root :to => "welcome#index"
end
