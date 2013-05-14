# -*- coding: utf-8 -*-

require 'spec_helper'

describe ParticipantsController do
  before do
    login(admin_login)
  end

  describe 'GET :index' do

    it "defaults being_followed_true to 1" do
      get :index
      assigns[:q].being_followed_true.should be_true
    end

    it "does not override user select of being_followed_true" do
      get :index, :q => { :being_followed_true => 0 }
      assigns[:q].being_followed_true.should_not be_true
    end

     # id sort for paginate
    it "defaults to sorting participants by id" do
      get :index
      assigns(:q).sorts[0].name.should == "id"
    end

    it "performs user selected sort first; id second" do
      get :index, :q => { :s => "p_id asc" }
      assigns(:q).sorts[0].name.should == "p_id"
      assigns(:q).sorts[1].name.should == "id"
    end

    describe "for a participant with many ppg_statuses" do
      let(:person) { Factory(:person)}
      let(:participant) { Factory(:participant, :being_followed => true) }
      before do
        participant.person = person
        participant.save!
        Factory(:ppg_detail, :participant => participant, :ppg_first_code => 1)
        [1,4].each { |x| Factory(:ppg_status_history, :participant => participant, :ppg_status_code => x) }
      end

      it "returns only one record for that participant" do
        get :index, :q => { :ppg_status_histories_ppg_status_code_eq => '',
          :ppg_details_ppg_first_code_eq => '',
          :participant_person_links_relationship_code_eq => 1,
          :participant_person_links_person_first_name_start => person.first_name }
        assigns(:participants).all.size.should == 1
      end
    end

  end

  describe 'GET :show' do
    describe ':id resolution' do
      let!(:p1) { Factory(:participant, :id => 9000, :p_id => '4500', :person => Factory(:person, :person_id => 'A')) }
      let!(:p2) { Factory(:participant, :id => 6000, :p_id => '9000', :person => Factory(:person, :person_id => 'B')) }
      let!(:p3) { Factory(:participant, :id => 3000, :p_id => '1500', :person => Factory(:person, :person_id => 'C')) }

      before do
        InstrumentPlan.stub!(:from_schedule).and_return(InstrumentPlan.new)
      end

      it 'resolves as the database ID first' do
        get :show, :id => '9000'

        assigns[:participant].should == p1
      end

      it 'resolves as the participant public ID second' do
        get :show, :id => '1500'

        assigns[:participant].should == p3
      end

      it 'resolves as the participant person ID third' do
        get :show, :id => 'B'

        assigns[:participant].should == p2
      end

      describe 'when the ID cannot be resolved' do
        it 'fails with the standard exception type' do
          expect { get :show, :id => '1' }.
            to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'fails with a useful error message' do
          expect { get :show, :id => 'Z' }.
            to raise_error(/Couldn't find Participant with id=Z or p_id=Z or self person_id=Z/)
        end
      end
    end

    describe 'contact link and events selection' do
      before do
        InstrumentPlan.stub!(:from_schedule).and_return(InstrumentPlan.new)
        @mother = Factory(:person)
        @m_participant = Factory(:participant)
        @m_participant.person = @mother
        @m_participant.save!

        @child = Factory(:person)
        @child.save!
        @c_participant = @m_participant.create_child_participant!(@child)

        # Event withough start date, time or contact_link
        @event = Factory(:event,
                         :participant => @m_participant,
                         :event_start_date => Date.new(2012,7,7),
                         :event_start_time => '22:37'
                        )
        # Event with start date, time and a contact_link
        @cl_ev = Factory(:event,
                         :participant => @m_participant,
                         :event_start_date => Date.new(2012,7,7),
                         :event_start_time => '20:33'
                        )
        # Contact_link not associated with an event
        c1 = Factory(:contact)
        c1.contact_date_date = Date.new(2012,8,8)
        c1.contact_start_time = '23:59'
        @cl = Factory(
          :contact_link,
          :person => @mother,
          :provider => nil,
          :contact => c1,
          :event => nil
        )
        # Mother's contact_link associated with mother's event
        @cl_ev_mother = Factory(
          :contact_link,
          :person => @mother,
          :provider => nil,
          :contact => Factory(:contact),
          :event => @cl_ev
        )
        # Child's contact_link associated with mother's event
        @cl_ev_child = Factory(
          :contact_link,
          :person => @child,
          :provider => nil,
          :contact => Factory(:contact),
          :event => @cl_ev
        )
      end
      it "selects 1 contact_link and 2 events related to the mother" do
        get :show, :id => @m_participant.id
        assigns[:events_and_contacts].count.should == 3
      end

      it "select mother's event with a contact_link related to the child" do
        get :show, :id => @c_participant.id
        assigns[:events_and_contacts].first.should == @cl_ev
      end

    end
  end
end
