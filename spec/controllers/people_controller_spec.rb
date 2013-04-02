# -*- coding: utf-8 -*-


require 'spec_helper'

describe PeopleController do

  context "with an authenticated, authorized user" do
    before(:each) do
      login(admin_login) # authorized user
      @person1 = Factory(:person, :first_name => "Jane",  :last_name => "Doe")
      @person2 = Factory(:person, :first_name => "Alice", :last_name => "Doe")
      @person3 = Factory(:person, :first_name => "Annie", :last_name => "Hall")
    end

    describe "GET index" do

      before(:each) do
        Person.count.should == 3
      end

      # id sort for paginate
      it "defaults to sorting people by id" do
        get :index
        assigns(:q).sorts[0].name.should == "id"
      end

      it "performs user selected sort first; id second" do
        get :index, :q => { :s => "last_name asc" }
        assigns(:q).sorts[0].name.should == "last_name"
        assigns(:q).sorts[1].name.should == "id"
      end

      describe "without search parameters" do
        it "assigns all people as @people" do
          get :index
          assigns[:people].count.should equal(3)
          assigns[:people].should include @person1
          assigns[:people].should include @person2
          assigns[:people].should include @person3
        end
      end

      describe "searching by last name" do
        it "returns complete matches" do
          get :index, :q => { :last_name_start => "Doe" }
          assigns[:people].count.should equal(2)
          assigns[:people].should include @person1
          assigns[:people].should include @person2
          assigns[:people].should_not include @person3
        end

        it "returns partial matches" do
          get :index, :q => { :last_name_start => "Do" }
          assigns[:people].count.should equal(2)
          assigns[:people].should include @person1
          assigns[:people].should include @person2
          assigns[:people].should_not include @person3
        end
      end

      describe "searching by first name" do
        it "returns complete matches" do
          get :index, :q => { :first_name_start => "Jane" }
          assigns[:people].count.should equal(1)
          assigns[:people].should include @person1
          assigns[:people].should_not include @person2
          assigns[:people].should_not include @person3
        end

        it "returns partial matches" do
          get :index, :q => { :first_name_start => "Ja" }
          assigns[:people].count.should equal(1)
          assigns[:people].should include @person1
          assigns[:people].should_not include @person2
          assigns[:people].should_not include @person3
        end
      end
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

  end

  context "with an authenticated yet unauthorized user"  do
    before(:each) do
      login(user_login) # unauthorized user
      @person1 = Factory(:person, :first_name => "Jane",  :last_name => "Doe")
    end

    describe "GET index" do
      before(:each) do
        Person.count.should == 1
      end

      describe "unauthorized attempt to access" do
        it "gives a forbidden status code for attempted at unauthorized access" do
          expect { get :index }.should raise_exception("uncaught throw :warden")
        end
      end
    end
  end

end
