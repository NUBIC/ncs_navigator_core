# -*- coding: utf-8 -*-


require 'spec_helper'

describe PeopleController do

  context "with an authenticated, authorized user" do
    let(:provider) { Factory(:provider) }
    before(:each) do
      login(admin_login) # authorized user
      @person1 = Factory(:person, :first_name => "Jane",  :last_name => "Doe")
      @person2 = Factory(:person, :first_name => "Alice", :last_name => "Doe")

      @person3 = Factory(:person, :first_name => "Annie", :last_name => "Hall")
      Factory(:person_provider_link, :provider => provider, :person => @person3)

      @batch1  = Factory(:person)
      Factory(:person_provider_link, :ineligibility_batch_identifier => "UUID",
              :provider => provider, :person => @batch1)
    end

    describe "GET new" do

      before do
        Date.stub!(:today => Date.parse('2525-12-25'))
      end

      it "assigns a new person as @person" do
        get :new
        assigns(:person).should be_a_new(Person)
      end

      it "sets the p_info_date attribute to today by default" do
        get :new
        assigns(:person).p_info_date.should == Date.today
      end

      it "sets the p_info_update attribute to today by default" do
        get :new
        assigns(:person).p_info_update.should == Date.today
      end

      it "sets the p_info_source_code attribute to 1 (Person/Self) by default" do
        get :new
        assigns(:person).p_info_source_code.should == Person.person_self_code
      end
    end

    describe "GET edit" do

      let(:person) { Factory(:person, :p_info_source_code => 2, :p_info_date => 1.day.ago.to_date) }

      it "assigns the requested person as @person" do
        get :edit, :id => person.id
        assigns(:person).should eq(person)
      end

      it "sets the p_info_date attribute to the previously known p_info_date" do
        previous = person.p_info_date
        get :edit, :id => person.id
        assigns(:person).p_info_date.should == previous
      end

      it "sets the p_info_date attribute to created_at if not set" do
        per = Factory(:person, :p_info_date => nil, :created_at => 3.days.ago)
        get :edit, :id => per.id
        assigns(:person).p_info_date.should == per.created_at.to_date
      end


      it "sets the p_info_update attribute to today by default" do
        get :edit, :id => person.id
        assigns(:person).p_info_update.should == Date.today
      end

      it "sets the p_info_source_code attribute the previously known p_info_source_code" do
        previous = person.p_info_source_code
        get :edit, :id => person.id
        assigns(:person).p_info_source_code.should == previous
      end
    end

    describe "GET new_child" do
      it "raises exception when no participant is given" do
        expect do
          get :new_child, :participant_id => nil
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises exception when no contact_link is given" do
        expect do
          get :new_child, :contact_link_id => nil, :participant => Factory(:participant)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "POST create_child" do

      let(:mother) { Factory(:person) }
      let(:mother_participant) { Factory(:participant) }
      let(:contact_link) { Factory(:contact_link) }
      let(:fname) { "John" }
      let(:lname) { "Doe" }

      before do
        mother_participant.person = mother
        mother_participant.save!
      end

      it "creates a child person and participant record associated with the mother participant" do
        mother_participant.children.should be_empty

        post :create_child, :participant_id => mother_participant.id, :contact_link_id => contact_link.id, :relationship_code => '8',
             :person => { :first_name => fname, :last_name => lname, :sex_code => "1",  }

        pt = Participant.find(mother_participant.id)
        pt.children.size.should == 1
        child = pt.children.first
        child.first_name.should == fname
        child.last_name.should == lname

        child_participant = child.participant
        child_participant.should_not be_nil
        child_participant.mother.should == mother
      end

      it "redirects to the contact link decision page" do
        post :create_child, :participant_id => mother_participant.id, :contact_link_id => contact_link.id, :relationship_code => '8',
             :person => { :first_name => fname, :last_name => lname, :sex_code => "1",  }
        response.should redirect_to(decision_page_contact_link_path(contact_link))
      end
    end

    context "starting an internal survey" do
      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant) }
      let(:contact) { Factory(:contact) }
      let!(:contact_link) { Factory(:contact_link, :contact => contact, :person => person) }
      let(:survey) { Factory(:survey, :access_code => "asdf") }

      describe "GET start_consent" do
        before do
          participant.participant_consents.size.should == 0
        end

        it "creates a new ParticipantConsent record for the Participant" do
          get :start_consent, :id => person.id,
                              :participant_id => participant.id,
                              :survey_access_code => survey.access_code,
                              :contact_link_id => contact_link.id
          pt = Participant.find participant.id
          pt.participant_consents.size.should == 1
        end

        it "redirects to the edit_my_survey_path" do
          get :start_consent, :id => person.id,
                              :participant_id => participant.id,
                              :survey_access_code => survey.access_code,
                              :contact_link_id => contact_link.id
          pt = Participant.find participant.id
          rs_access_code = pt.participant_consents.first.response_set.try(:access_code)
          response.should redirect_to(edit_my_survey_path(:survey_code => survey.access_code,
            :response_set_code => rs_access_code))
        end
      end

      describe "GET start_non_interview_report" do
        before do
          person.non_interview_reports.size.should == 0
        end

        it "creates a new ParticipantConsent record for the Participant" do
          get :start_non_interview_report, :id => person.id,
                                           :participant_id => participant.id,
                                           :survey_access_code => survey.access_code,
                                           :contact_link_id => contact_link.id
          pr = Person.find person.id
          pr.non_interview_reports.size.should == 1
        end

        it "redirects to the edit_my_survey_path" do
          get :start_non_interview_report, :id => person.id,
                                           :participant_id => participant.id,
                                           :survey_access_code => survey.access_code,
                                           :contact_link_id => contact_link.id
          pr = Person.find person.id
          rs_access_code = pr.non_interview_reports.first.response_set.try(:access_code)
          response.should redirect_to(edit_my_survey_path(:survey_code => survey.access_code,
            :response_set_code => rs_access_code))
        end
      end
    end

    context "with a provider" do

      let(:provider) { Factory(:provider) }

      describe "GET new" do
        it "assigns a new provider as @provider" do
          get :new, :provider_id => provider.id
          assigns(:provider).should == provider
        end
      end
    end

    context "batch handling" do
      before :each do
        @params = {
          "people"=>{"number"=>"5"},
          "person"=>
            {"person_provider_links_attributes"=>
              {"0"=>
                {"provider_id"=>"#{provider.id}",
                "pre_screening_status_code"=>"2",
                "sampled_person_code"=>"1",
                "date_first_visit"=>"2013-03-12",
                "provider_intro_outcome_code"=>"-5",
                "provider_intro_outcome_other"=>"asdf"}},
            "sampled_persons_ineligibilities_attributes"=>
              {"0"=>
                {"provider_id"=>"#{provider.id}",
                "age_eligible_code"=>"1",
                "county_of_residence_code"=>"1",
                "pregnancy_eligible_code"=>"2",
                "first_prenatal_visit_code"=>"2",
                "ineligible_by_code"=>"1"}}},
          "commit"=>"Submit",
          "action"=>"create_batch",
          "controller"=>"people",
          "provider_id"=>"#{provider.id}"
        }
      end

      describe "POST create_batch" do
        before do
          @batch1.destroy
        end

        describe "with html request" do
          it "creates 5 new ineligibility_batch people" do
            expect {
              post :create_batch, @params
            }.to change(Person, :count).by(5)
            Person.in_ineligibility_batch.count.should == 5
          end

          it "creates ineligibilities records" do
            post :create_batch, @params
            ineligibilities = Person.in_ineligibility_batch.first.sampled_persons_ineligibilities.first
            ineligibilities.age_eligible_code.should == 1
            ineligibilities.county_of_residence_code.should == 1
            ineligibilities.pregnancy_eligible_code.should == 2
            ineligibilities.first_prenatal_visit_code.should == 2
            ineligibilities.ineligible_by_code.should == 1
          end

          it "creates provider records" do
            post :create_batch, @params
            ppl= Person.in_ineligibility_batch.first.person_provider_links.first
            ppl.ineligibility_batch_identifier.should_not be_blank
            ppl.provider_id.should == provider.id
            ppl.pre_screening_status_code.should == 2
            ppl.sampled_person_code.should == 1
            ppl.date_first_visit.should == "2013-03-12"
            ppl.provider_intro_outcome_code.should == -5
            ppl.provider_intro_outcome_other.should == "asdf"
          end

          it "doesn't create ineligibilities if no related arguments passed" do
            @params["person"]["sampled_persons_ineligibilities_attributes"][
                    "0"] = {
                            "provider_id"=>"#{provider.id}",
                            "age_eligible_code"=>"",
                            "county_of_residence_code"=>"",
                            "pregnancy_eligible_code"=>"",
                            "first_prenatal_visit_code"=>"",
                            "ineligible_by_code"=>""
            }
            post :create_batch, @params
            Person.in_ineligibility_batch.first.sampled_persons_ineligibilities.should be_blank
          end
        end
      end

      describe "DELETE delete_batch" do
        describe "with html request" do
          it "deletes 5 people created by #create_batch, leaves others alone" do
            post :create_batch, @params
            Person.in_ineligibility_batch.count.should == 6
            Person.all.count.should == 9
            uuid = PersonProviderLink.where("ineligibility_batch_identifier != ?",
              @batch1.person_provider_links.first.ineligibility_batch_identifier
                                           ).first.ineligibility_batch_identifier

            expect {
              delete :delete_batch, :ineligibility_batch_identifier => uuid,
                     :provider_id => provider.id
            }.to change(Person, :count).by(-5)
            Person.in_ineligibility_batch.count.should == 1
            Person.all.count.should == 4
          end
        end
      end

    end

  end

end
