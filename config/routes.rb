NcsNavigatorCore::Application.routes.draw do
  resources :dwelling_units do
    member do
      put :create_household_unit
    end
  end
  resources :household_units
  resources :addresses, :except => [:destroy]
  resources :events, :only => [:index, :edit, :update] do
    member do
      get :versions
      get :reschedule
      put :reschedule
    end
  end
  resources :people do
    member do
      get :versions
      get :events
      get :start_instrument
      get :responses_for
      put :responses_for
    end
    resources :contacts, :except => [:index]
    resources :telephones, :except => [:index, :destroy]
    resources :emails, :except => [:index, :destroy]
  end
  resources :participants do
    collection do
      get :in_ppg_group
    end
    member do
      get :versions
      get :edit_arm
      put :update_arm
      put :register_with_psc
      put :schedule_next_event_with_psc
      get :schedule
      get :edit_ppg_status
      put :update_ppg_status
      get :correct_workflow
      put :process_update_state
    end
  end
  resources :contact_links do
    member do
      get :select_instrument
      get :edit_instrument
      put :finalize_instrument
    end
  end
  resources :non_interview_reports, :except => [:index, :destroy, :show]
  resources :participant_consents

  namespace :api do
    scope '/v1' do
      resources :fieldwork, :only => [:create, :update, :show]
    end
  end

  match "/faq", :to => "welcome#faq", :via => [:get]
  match "/reports", :to => "reports#index", :via => [:get]
  match "/reports/index", :to => "reports#index", :via => [:get]
  match "/reports/case_status", :to => "reports#case_status", :via => [:get, :post]
  match "/reports/upcoming_births", :to => "reports#upcoming_births", :via => [:get]
  match "/reports/ppg_status", :to => "reports#ppg_status", :via => [:get]
  match "/reports/number_of_consents_by_type", :to => "reports#number_of_consents_by_type", :via => [:get]
  match "/reports/consented_participants", :to => "reports#consented_participants", :via => [:get]

  match "/welcome/summary", :to => "welcome#summary"
  match "/welcome/upcoming_activities", :to => "welcome#upcoming_activities"
  match "/welcome/overdue_activities", :to => "welcome#overdue_activities"
  match "/welcome/pending_events", :to => "welcome#pending_events"
  match "welcome/start_pregnancy_screener_instrument", :to => "welcome#start_pregnancy_screener_instrument", :as => "start_pregnancy_screener_instrument"

  root :to => "welcome#index"

  match 'surveyor/finalize_instrument/:response_set_id' => 'surveyor#finalize_instrument', :via => [:get]
end
