# -*- coding: utf-8 -*-

NcsNavigatorCore::Application.routes.draw do
  mount Surveyor::Engine => "/surveys", :as => "surveyor"

  resources :dwelling_units do
    member do
      put :create_household_unit
    end
  end
  resources :household_units
  resources :addresses, :except => [:destroy]
  resources :emails, :except => [:index, :destroy]
  resources :telephones, :except => [:index, :destroy]
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
      get :start_consent
      get :start_non_interview_report
      get :responses_for
      put :responses_for
      get :provider_staff_member
      get :provider_staff_member_radio_button
      get :edit_child
      put :update_child
    end
    collection do
      get :new_child
      post :create_child
    end
    resources :contacts, :except => [:index]
    resources :telephones, :except => [:index, :destroy]
    resources :emails, :except => [:index, :destroy]
    resources :non_interview_reports, :only => [:edit, :update]
  end
  resources :participants do
    collection do
      get :in_ppg_group
    end
    member do
      get :versions
      get :edit_arm
      put :update_psc
      put :update_arm
      put :register_with_psc
      put :schedule_next_event_with_psc
      put :schedule_informed_consent_event
      put :schedule_reconsent_event
      put :schedule_withdrawal_event
      put :schedule_child_consent_birth_to_six_months_event
      put :schedule_child_consent_six_month_to_age_of_majority_event
      get :schedule
      get :edit_ppg_status
      put :update_ppg_status
      get :correct_workflow
      put :process_update_state
      get :mark_event_out_of_window
      put :process_mark_event_out_of_window
      put :enroll
      put :unenroll
      put :remove_from_active_followup
      get :low_intensity_postnatal_scheduler
      put :schedule_low_intensity_postnatal
      get :cancel_pending_events
      put :nullify_pending_events
    end
    resources :participant_consents, :only => [:edit]
    resources :ppg_details, :only => [:edit, :update]
  end
  resources :contact_links do
    member do
      get :select_instrument
      get :edit_instrument
      put :finalize_instrument
      get :decision_page
      get :saq_instrument
    end
    resources :instruments, :except => [:index, :destroy]
    resources :events, :except => [:index, :destroy]
    resources :contacts, :except => [:index, :destroy]
  end

  resources :instruments, :except => [:index, :destroy]
  resources :non_interview_reports, :except => [:index, :destroy, :show]
  resources :participant_consents do
    collection do
      get :new_child
      post :create_child
    end
  end
  resources :participant_visit_records
  resources :participant_visit_consents
  resources :institutions
  resources :providers do
    member do
      get :edit_contact_information
      put :update_contact_information
      get :staff_list
      get :new_staff
      post :create_staff
      get :edit_staff
      put :update_staff
      get :contact_log
      get :post_recruitment_contact
      get :recruited
      put :process_recruited
      get :refused
      put :process_refused
    end
    resources :ineligible_batches
    resources :non_interview_providers, :except => [:destroy]
    resources :people, :except => [:index, :destroy, :show]
  end
  resources :pbs_lists, :except => [:new, :create] do
    member do
      get :recruit_provider
    end
    collection do
      get :upload
      post :upload
      get :sample_upload_file
    end
  end
  resources :contacts do
    collection do
      get :provider_recruitment
      post :provider_recruitment
    end
  end

  resources :specimens do
    collection do
      post :verify
      get  :verify
      post :generate
      post :send_email
    end
  end

  resources :samples do
    collection do
      post :verify
      get  :verify
      post :generate
      post :send_email
    end
  end

  resources :specimen_processing_shipping_centers
  resources :sample_receipt_shipping_centers
  resources :specimen_pickups, :only => [:new, :create, :show]
  resources :specimen_sample_processes do
    collection do
      get :index
      post :receive
      post :store
      put :store
    end
  end

  resources :specimen_receipts
  resources :specimen_receipt_confirmations
  resources :sample_shipping_confirmations
  resources :sample_receipt_confirmations
  resources :sample_processes
  resources :edit_sample_processes do
    collection do
      post :search_by_id
      post :search_by_date
    end
  end

  resources :specimen_shippings do
    collection do
      post :send_email
    end
  end

  resources :sample_shippings do
    collection do
      post :send_email
    end
  end

  resources :sample_receipt_stores do
    member do
      post :update
    end
  end

  resources :specimen_storages do
    member do
      post :update
    end
  end

  match "/shipping", :to => "shipping#index"

  namespace :api do
    scope '/v1' do
      resources :fieldwork, :only => [:create, :update, :show]
      resources :merges
      resources :code_lists, :only => :index
      resources :providers, :only => :index
      resources :events, :only => :index

      match '/system-status', :to => 'status#show'
    end
  end

  resources :fieldwork, :only => :index do
    resources :merges, :only => :show do
      collection do
        get :latest
      end
    end
  end

  match "/contact_links/update_psc_for_activity", :to => "contact_links#update_psc_for_activity", :via => [:post]

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
  match "welcome/start_pbs_eligibility_screener_instrument", :to => "welcome#start_pbs_eligibility_screener_instrument", :as => "start_pbs_eligibility_screener_instrument"
  match "appointment_sheet/:person/:date", :to => "appointment_sheets#show", :as => "appointment_sheet", :via => [:get]

  root :to => "welcome#index"

end
