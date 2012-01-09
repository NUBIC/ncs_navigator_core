NcsNavigatorCore::Application.routes.draw do
  resources :dwelling_units
  resources :household_units
  resources :events, :only => [:index]
  resources :people do
    member do
      get :events
      get :start_instrument
      get :responses_for
      put :responses_for
    end
    resources :contacts, :except => [:index]
  end
  resources :participants do
    collection do
      get :in_ppg_group
    end
    member do
      get :edit_arm
      put :update_arm
      put :register_with_psc
      put :schedule_next_event_with_psc
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
      get :edit_instrument
      put :finalize_instrument
    end
  end
  resources :participant_consents

  match "/welcome/summary", :to => "welcome#summary"
  match "/welcome/overdue_activities", :to => "welcome#overdue_activities"
  match "welcome/start_pregnancy_screener_instrument", :to => "welcome#start_pregnancy_screener_instrument", :as => "start_pregnancy_screener_instrument"

  root :to => "welcome#index"

  match 'surveyor/finalize_instrument/:response_set_id' => 'surveyor#finalize_instrument', :via => [:get]
end
