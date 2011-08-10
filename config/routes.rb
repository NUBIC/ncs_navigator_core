NcsNavigatorCore::Application.routes.draw do
  resources :dwelling_units
  resources :household_units
  resources :people do
    member do 
      get :events
      get :start_instrument
    end
    resources :contacts
  end
  resources :participants do
    member do
      get :edit_arm
      put :update_arm
    end
  end
  
  root :to => "welcome#index"
end
