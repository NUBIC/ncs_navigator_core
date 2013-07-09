# -*- coding: utf-8 -*-
require 'spec_helper'

describe WelcomeController do

  describe "GET restart_screener_for_ineligible" do
    context "with an authenticated user" do
      before(:each) do
        @person = Factory(:person)
        @inst = Factory(:instrument, person: @person)

        @event = Factory :event,
                         event_start_date: Date.parse('2013-06-26'),
                         event_end_date: nil,
                         event_end_time: nil,
                         event_type: NcsCode.pbs_eligibility_screener

        @contact = Factory(:contact)

        @contact_link = Factory :contact_link,
                                contact: @contact,
                                person: @person,
                                event: @event,
                                instrument: @inst

        @rs = Factory :response_set,
                      instrument: @inst,
                      person: @person

        ResponseSet.stub(:where).and_return([@rs])
        login(user_login)
      end

      describe "setting instance variables" do
        it "should set response set from params" do
          get :restart_screener_for_ineligible
          assigns[:response_set].should eql(@rs)
        end

        it "should set person from response set" do
          get :restart_screener_for_ineligible
          assigns[:person].should eql(@person)
        end
      end

      describe "redirecting" do
        it "should redirect to new person contact path for person" do
          get :restart_screener_for_ineligible
          response.should redirect_to(new_person_contact_path(@person))
        end
      end

      context "with a newly created participant" do
        it "should create a new participant" do
          expect{get :restart_screener_for_ineligible}.to change(Participant, :count).by(1)
        end

        it "should be associated to person" do
          get :restart_screener_for_ineligible
          assigns[:participant].person.should eql(@person)
        end
      end
    end
  end

end