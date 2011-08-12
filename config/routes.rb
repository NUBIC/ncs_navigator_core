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
  resources :contact_links
  
  root :to => "welcome#index"
  
  match 'surveyor/finalize_instrument/:response_set_id' => 'surveyor#finalize_instrument', :via => [:get]
end
