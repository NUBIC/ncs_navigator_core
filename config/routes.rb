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
    collection do
      get :in_ppg_group
    end
    member do
      get :edit_arm
      put :update_arm
      put :register_with_psc
      get :schedule
      get :edit_ppg_status
      put :update_ppg_status
      get :development_workflow
      put :development_update_state
    end
  end
  resources :contact_links do
    member do
      get :select_instrument
    end
  end
  
  root :to => "welcome#index"
  
  match 'surveyor/finalize_instrument/:response_set_id' => 'surveyor#finalize_instrument', :via => [:get]
end
