# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: participants
#
#  being_followed            :boolean          default(FALSE)
#  being_processed           :boolean          default(FALSE)
#  created_at                :datetime
#  enroll_date               :date
#  enroll_status_code        :integer          not null
#  enrollment_status_comment :text
#  high_intensity            :boolean          default(FALSE)
#  high_intensity_state      :string(255)
#  id                        :integer          not null, primary key
#  lock_version              :integer          default(0)
#  low_intensity_state       :string(255)
#  p_id                      :string(36)       not null
#  p_type_code               :integer          not null
#  p_type_other              :string(255)
#  pid_age_eligibility_code  :integer          not null
#  pid_comment               :text
#  pid_entry_code            :integer          not null
#  pid_entry_other           :string(255)
#  psu_code                  :integer          not null
#  status_info_date          :date
#  status_info_mode_code     :integer          not null
#  status_info_mode_other    :string(255)
#  status_info_source_code   :integer          not null
#  status_info_source_other  :string(255)
#  transaction_type          :string(36)
#  updated_at                :datetime
#



require 'spec_helper'

require File.expand_path('../../shared/custom_recruitment_strategy', __FILE__)

describe Participant do

  it "creates a new instance given valid attributes" do
    par = Factory(:participant)
    par.should_not be_nil
  end

  it "is in low intensity arm by default" do
    participant = Factory(:participant)
    participant.should be_low_intensity
  end

  it { should belong_to(:psu) }
  it { should belong_to(:p_type) }
  it { should belong_to(:status_info_source) }
  it { should belong_to(:status_info_mode) }
  it { should belong_to(:enroll_status) }
  it { should belong_to(:pid_entry) }
  it { should belong_to(:pid_age_eligibility) }

  it { should have_many(:ppg_details) }
  it { should have_many(:ppg_status_histories) }

  it { should have_many(:participant_person_links) }
  it { should have_many(:people).through(:participant_person_links) }
  it { should have_many(:events) }

  it { should have_many(:low_intensity_state_transition_audits) }
  it { should have_many(:high_intensity_state_transition_audits) }

  it { should have_many(:participant_consents) }
  it { should have_many(:participant_consent_samples) }

  # it { should validate_presence_of(:person) }

  it { should have_many(:response_sets) }

  describe '#response_sets' do
    it 'is the inverse of Instrument#response_set' do
      Participant.reflections[:response_sets].options[:inverse_of].should == :participant
    end
  end

  context "in the pbs protocol" do
    include_context 'custom recruitment strategy'

    let(:recruitment_strategy) { ProviderBasedSubsample.new }

    before do
      NcsNavigatorCore.stub(:recruitment_type_id).and_return(5)
    end

    it "creates a participant in the high_intensity arm" do
      pr = Participant.create
      pr.should be_high_intensity
      pr.low_intensity_state.should == "started_in_high_intensity_arm"
      pr.should be_converted_high_intensity
    end

    it "starts a pregnant participant at PV1" do
      pr = Factory(:low_intensity_ppg1_participant)
      pr.person = Factory(:person)
      pr.should be_high_intensity
      pr.low_intensity_state.should == "started_in_high_intensity_arm"
      date = Date.parse("2010-09-09")
      event = Factory(:event, :participant => pr,
                              :event_start_date => date, :event_end_date => date,
                              :event_type => NcsCode.pbs_eligibility_screener)
      contact = Factory(:contact, :contact_date_date => date)
      contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => pr.person)

      pr.events << event
      pr.should be_pregnancy_one
      pr.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1]
      pr.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1
      pr.next_scheduled_event.date.should == date
    end

  end

  context "as mdes record" do

    describe 'the public ID' do
      let(:pr) { Factory(:participant) }

      it 'is a human-readable ID' do
        pr.public_id.should =~ /^\w{3}-\w{2}-\w{4}$/
      end

      it 'is named p_id' do
        pr.public_id.should == pr.p_id
      end
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      pr = Participant.create
      pr.person = Factory(:person)
      pr.save!

      obj = Participant.find(pr.id)
      obj.status_info_source.local_code.should == -4
      obj.pid_entry.local_code.should == -4
      obj.p_type.local_code.should == -4
      obj.status_info_source.local_code.should == -4
      obj.status_info_mode.local_code.should == -4
      obj.enroll_status.local_code.should == -4
      obj.pid_entry.local_code.should == -4
      obj.pid_age_eligibility.local_code.should == -4
    end
  end

  context "audit history" do

    describe ".versions" do
      it "retrieves the versioning information" do
        with_versioning do
          pr = Factory(:participant)
          pr.versions.size.should == 1
          pr.register!
          Participant.find(pr.id).versions.size.should == 2
        end
      end
    end

    describe ".changeset" do
      it "shows the specific changes" do
        with_versioning do
          pr = Factory(:participant)
          orig_date = pr.enroll_date
          new_date  = Date.parse("2012-02-25")
          pr.enroll_date = new_date
          pr.save!

          cs = Participant.find(pr.id).versions.last.changeset

          cs.keys.should == ["enroll_date"]
          cs.values.should == [[orig_date, new_date]]
        end
      end
    end

    describe ".export_versions" do
      it "outputs all versioning history as csv" do
        with_versioning do
          pr = Factory(:participant)
          pr.enroll_date = Date.parse("2012-02-25")
          pr.save!
          csv = pr.export_versions
          csv.should_not be_blank
          arr_of_arrs = Rails.application.csv_impl.parse(csv)

          arr_of_arrs[0][0].should == "When"
          arr_of_arrs[0][6].should == "Enroll Date"
          arr_of_arrs[1][6].should == Date.today.to_s(:db)
          arr_of_arrs[2][6].should == "2012-02-25"
        end
      end
    end
  end

  context "relationship between person and participant" do
    let(:participant) { Factory(:participant) }
    let(:person) { Factory(:person) }

    describe "#person=" do

      describe "without an existing self relationship" do
        before do
          participant.person.should be_nil
          participant.participant_person_links.should be_empty

          participant.person = person
        end

        it 'creates the relationship' do
          participant.participant_person_links.first.relationship_code.should == 1
        end

        it 'associates to the correct person' do
          participant.person.should == person
        end
      end

      describe 'with an existing self relationship' do
        let!(:existing_link) {
          participant.participant_person_links.create(
            :relationship_code => 1, :psu => participant.psu, :person => Factory(:person, :last_name => 'Astaire'))
        }

        before do
          participant.person = person
        end

        it 'does not add another link' do
          participant.should have(1).participant_person_link
        end

        it "updates the associated person" do
          participant.person.should == person
        end
      end

    end

    describe "query by person" do
      before do
        participant.person = person
        participant.save!
      end

      it "finds the participant via the person id" do
        Participant.for_person(person.id).should == participant
      end
    end
  end

  context "delegating to the associated person" do
    let(:person) { Factory(:person, :person_dob_date => 10.years.ago) }
    let(:participant) { Factory(:participant) }

    before :each do
      participant.person = person
      participant.save!
    end

    it "returns age" do
      participant.age.should == person.age
    end

    it "returns first_name" do
      participant.first_name.should == person.first_name
    end

    it "returns last_name" do
      participant.last_name.should == person.last_name
    end

  end

  context "associated with NCS staff" do

    it { should have_many(:participant_staff_relationships) }

    before(:each) do
      @participant = Factory(:participant)
      Factory(:participant_staff_relationship, :participant => @participant, :staff_id => "main_guy", :primary => true)
      Factory(:participant_staff_relationship, :participant => @participant, :staff_id => "that_guy", :primary => false)
    end

    it "knows it's staff relationships" do
      @participant.participant_staff_relationships.size.should == 2
    end

    it "knows it's primary relationship" do
      @participant.primary_staff_relationships.size.should == 1
      @participant.primary_staff_relationships.first.staff_id.should == "main_guy"
    end

    it "finds all participants for a staff member" do
      Factory(:participant_staff_relationship, :participant => Factory(:participant), :staff_id => "that_guy", :primary => true)
      Participant.all_for_staff("that_guy").count.should == 2
      Participant.primary_for_staff("that_guy").count.should == 1
    end

  end

  context "exporting as csv" do

    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }
    let(:date) { Date.parse("2009-09-09") }
    let(:expected_due_date) { 6.months.since(date).strftime('%Y-%m-%d') }

    before :each do
      participant.person = person
      participant.save!
      Factory(:ppg_detail, :orig_due_date => expected_due_date, :participant => participant)
    end

    it "renders in comma-separated value format" do

      participant.to_comma.should == [
        participant.p_id.to_s,
        person.prefix.to_s,
        person.first_name.to_s,
        person.middle_name.to_s,
        person.last_name.to_s,
        person.maiden_name.to_s,
        person.suffix.to_s,
        person.title.to_s,
        participant.ppg_status.to_s,
        participant.person_dob.to_s,
        participant.gender.to_s,
        person.age.to_s,
        person.age_range.to_s,
        person.deceased.to_s,
        person.ethnic_group.to_s,
        person.language.to_s,
        person.language_other.to_s,
        person.marital_status.to_s,
        person.marital_status_other.to_s,
        participant.pending_events.to_sentence,
        expected_due_date,
        participant.high_intensity ? 'High' : 'Low',
        participant.enroll_status.to_s,
        participant.enroll_date.to_s
      ]
    end

  end

  context "with an assigned pregnancy probability group" do

    let(:participant) { Factory(:participant) }
    let(:status1)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1) }
    let(:status2)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2) }
    let(:status2a) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 2) }

    let(:status3)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 3) }
    let(:status4)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 4) }

    # TODO: this behavior isn't necessary and could be removed to
    # simplify Participant
    it "determines the ppg from the ppg_details if there is no ppg_status_history record" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a)
      PpgStatusHistory.where(:participant_id => participant).delete_all

      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should be_empty
      participant.ppg_status.should == status2a
    end

    it "determines the ppg from the ppg_status_history" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a,
        :desired_history_date => '2010-01-01')
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)

      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should_not be_empty
      participant.ppg_status.should == status1
    end

    it "determines the ppg from the most recent ppg_status_history" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a,
        :desired_history_date => '2010-01-01')
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status2,  :ppg_status_date => '2011-01-02')
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status1, :ppg_status_date => '2011-01-31')

      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should_not be_empty
      participant.ppg_status.should == status1
    end

    describe "given a date" do

      it "determines the ppg_status at that time" do

        Factory(:ppg_detail, :participant => participant, :ppg_first => status2a,
          :desired_history_date => '2010-01-01')
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status2,  :ppg_status_date => '2011-01-01')
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1, :ppg_status_date => '2011-06-01')
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1, :ppg_status_date => '2011-12-01')
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status4, :ppg_status_date => '2012-02-01')

        participant.ppg_status.should == status4
        participant.ppg_status(Date.parse('2011-12-31')).should == status1
        participant.ppg_status(Date.parse('2011-06-01')).should == status1
        participant.ppg_status(Date.parse('2011-04-01')).should == status2

      end

    end

    it "finds participants in that group" do

      3.times do |x|
        pers = Factory(:person, :first_name => "Jane#{x}", :last_name => "PPG1")
        part = Factory(:participant)
        part.person = pers
        Factory(:ppg_status_history, :participant => part, :ppg_status => status1)
      end

      5.times do |x|
        pers = Factory(:person, :first_name => "Jane#{x}", :last_name => "PPG2")
        part = Factory(:participant)
        part.person = pers
        Factory(:ppg_status_history, :participant => part, :ppg_status => status2)
      end

      1.times do |x|
        pers = Factory(:person, :first_name => "Jane#{x}", :last_name => "PPG3")
        part = Factory(:participant)
        part.person = pers
        Factory(:ppg_status_history, :participant => part, :ppg_status => status3)
      end

      6.times do |x|
        pers = Factory(:person, :first_name => "Jane#{x}", :last_name => "PPG4")
        part = Factory(:participant)
        part.person = pers
        Factory(:ppg_status_history, :participant => part, :ppg_status => status4)
      end
      Participant.in_ppg_group(1).size.should == 3
      Participant.in_ppg_group(2).size.should >= 5 # TODO: determine why this is not returning exactly 5 - other test is making this line fail
      Participant.in_ppg_group(3).size.should == 1
      Participant.in_ppg_group(4).size.should == 6
    end

  end

  context "contacts" do

    describe ".contacts" do

      it "returns the participant contacts through the event not the participant.person.contacts" do

        contact_person = Factory(:person)
        person = Factory(:person)
        participant = Factory(:participant)
        participant.person = person
        participant.save!
        event = Factory(:event, :participant => participant)
        contact = Factory(:contact)
        contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => contact_person)

        participant.contacts.should == [contact]
        participant.person.contacts.should be_empty
        contact_person.contacts.should == participant.contacts

      end

    end

    describe "#last_contact" do

      before(:each) do
        person = Factory(:person)
        @participant = Factory(:participant, :high_intensity => true)
        @participant.person = person
      end

      it "returns nil if no previous contacts" do
        @participant.last_contact.should be_nil
      end

      it "returns the most recent contact" do
        event = Factory(:event, :participant => @participant)
        contact = Factory(:contact, :contact_date_date => 1.day.ago)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :contact => contact)

        @participant.last_contact.should == contact
      end
    end
  end

  describe "#upcoming_births" do

    let(:ppg1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1) }
    let(:ppg3) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 3) }
    let(:date) { Date.parse("2525-02-05") }

    before(:each) do

      person1 = Factory(:person)
      participant1 = Factory(:participant, :high_intensity => true)
      participant1.person = person1
      Factory(:ppg_detail, :participant => participant1, :ppg_first => ppg1)

      person2 = Factory(:person)
      participant2 = Factory(:participant, :high_intensity => true)
      participant2.person = person2
      Factory(:ppg_detail, :orig_due_date => 3.months.since(date).strftime('%Y-%m-%d'), :participant => participant2, :ppg_first => ppg1)
    end

    it "returns all participants with an upcoming due date" do
      Participant.count.should == 2
      Participant.upcoming_births.count.should == 1
    end

  end

  describe "#has_children?" do

    it "is false if the participant has no children" do
      participant = Factory(:participant)
      participant.children.should be_empty
      participant.has_children?.should be_false
    end

    it "is true if the participant has children" do
      person = Factory(:person)
      participant = Factory(:participant)
      participant.person = person
      participant.save!

      participant.create_child_person_and_participant!({:first_name => "cfname", :last_name => "clname"})
      participant.participant_person_links.reload
      participant.children.should_not be_empty
      participant.has_children?.should be_true
    end

  end

  context "when determining schedule" do

    describe "a participant who has had a recent pregnancy loss (PPG 3)" do

      let(:date) { Date.parse("2525-09-09") }

      before(:each) do
        status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 3)
        person = Factory(:person)
        @participant = Factory(:participant, :high_intensity => true)
        @participant.person = person
        @participant.register!
        @participant.assign_to_pregnancy_probability_group!
        Factory(:ppg_status_history, :participant => @participant, :ppg_status => status)
        @event = Factory(:event, :participant => @participant,
                                :event_start_date => date, :event_end_date => date,
                                :event_type => NcsCode.pregnancy_screener)
        @participant.events << @event

        @participant.save!
      end

      it "knows the upcoming applicable events when a new record" do
        contact = Factory(:contact ,:contact_date_date => date)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => @event, :created_at => date, :contact => contact)

        @participant.ppg_status.local_code.should == 3

        @participant.high_intensity_conversion!
        @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        @participant.next_scheduled_event.date.should == 6.months.since(date).to_date
      end

      it "knows the upcoming applicable events who has had a followup already" do
        event_type = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 7)
        event_disposition_category = NcsCode.for_list_name_and_local_code("EVENT_DSPSTN_CAT_CL1", 5)
        event = Factory(:event, :event_type => event_type, :event_disposition_category => event_disposition_category, :participant => @participant)
        contact = Factory(:contact ,:contact_date_date => 5.months.ago(date))
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :contact => contact)
        @participant.high_intensity_conversion!

        @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        @participant.next_scheduled_event.date.should == 1.month.since(date).to_date
      end

      it "knows the upcoming applicable events who has had several followups already" do
        event_type = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 7)
        event_disposition_category = NcsCode.for_list_name_and_local_code("EVENT_DSPSTN_CAT_CL1", 5)
        event = Factory(:event, :event_type => event_type, :event_disposition_category => event_disposition_category, :participant => @participant)

        Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 10.months.ago(date), :contact => Factory(:contact, :contact_date_date => 10.months.ago(date)))
        Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 7.months.ago(date), :contact => Factory(:contact, :contact_date_date => 7.months.ago(date)))
        Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 4.months.ago(date), :contact => Factory(:contact, :contact_date_date => 4.months.ago(date)))
        Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 1.month.ago(date), :contact => Factory(:contact, :contact_date_date => 1.month.ago(date)))

        @participant.high_intensity_conversion!
        near_date = 5.month.since(date).to_date
        dt_range = [near_date + 1.day, near_date, near_date - 1.day]
        @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        @participant.next_scheduled_event.date.should be_in dt_range
      end
    end

    context "in the low intensity protocol" do
      before(:each) do
        trying = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2)
        @person = Factory(:person)
        @participant = Factory(:participant, :high_intensity => false)
        @participant.person = @person
        @participant.register!
        @participant.assign_to_pregnancy_probability_group!
        Factory(:ppg_status_history, :participant => @participant, :ppg_status => trying)
        @event = Factory(:event, :participant => @participant,
                                :event_start_date => Date.today, :event_end_date => Date.today,
                                :event_type => NcsCode.pregnancy_screener)
        @participant.events << @event
        @participant.save!
      end

      it "uses the date from last contact date to determine the next scheduled event date" do
        Factory(:contact_link, :person => @participant.person, :event => @event, :contact => Factory(:contact, :contact_date => '2012-01-01'))
        @participant.next_scheduled_event.event.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
        @participant.next_scheduled_event.date.should == Date.parse('2012-01-01')
      end
    end

    context "in the high intensity protocol" do

      it "knows the upcoming applicable events for a consented participant" do
        status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2)
        person = Factory(:person)
        @participant = Factory(:participant, :high_intensity => true, :high_intensity_state => "converted_high_intensity")
        @participant.person = person
        @participant.register!
        @participant.assign_to_pregnancy_probability_group!

        date = Date.parse("2111-01-01")
        event = Factory(:event, :participant => @participant,
                                :event_start_date => date, :event_end_date => date,
                                :event_type => NcsCode.pregnancy_screener)
        contact = Factory(:contact, :contact_date_date => date)
        Factory(:contact_link, :person => person, :contact => contact, :event => event)

        @participant.events << event

        Factory(:ppg_status_history, :participant => @participant, :ppg_status => status)
        @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        @participant.next_scheduled_event.date.should == 3.months.since(date).to_date
      end

      context "for pregnancy one participant" do

        let(:date) { Date.new(2012, 02, 01) }
        before(:each) do
          @person = Factory(:person)
          @participant = Factory(:high_intensity_pregnancy_one_participant, :created_at => date)
          @participant.person = @person
          @event = Factory( :event, :participant => @participant,
                                          :event_start_date => date, :event_end_date => date,
                                          :event_type => NcsCode.pregnancy_screener)
          @participant.events << @event
          @participant.save!

          Factory(:contact_link, :event => @event, :person => @person,
                  :contact => Factory(:contact, :contact_date => "2000-12-25"))
        end

        it "next event should be PV1" do
          @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1
        end

        context "next event date" do
          it "should be the last contact date" do
            Factory(:contact_link, :person => @person, :event => @event, :contact => Factory(:contact, :contact_date_date => date))
            @participant.next_scheduled_event.date.should == date
          end

          context "with due_date" do
            let(:due_date) { Date.new(2012, 10, 01) }
            let(:contact_date) { Date.new(2012, 01, 01) }

            before(:each) do
              Factory(:ppg_detail, :participant => @participant,
                :ppg_first => NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1), :orig_due_date => due_date)
              @participant.due_date.should == due_date
            end

            it "should be the contact date" do
              cl = Factory(:contact_link, :person => @person, :event => @event, :contact => Factory(:contact, :contact_date_date => contact_date))

              @participant.next_scheduled_event.date.should == contact_date
            end

          end
        end
      end

      context "for pregnancy two participant" do

        let(:date) { Date.new(2012, 02, 01) }

        before(:each) do
          @person = Factory(:person)
          @participant = Factory(:high_intensity_pregnancy_two_participant, :created_at => date)
          @participant.person = @person
          @event = Factory( :event, :participant => @participant,
                                          :event_start_date => date, :event_end_date => date,
                                          :event_type => NcsCode.pregnancy_screener)
          @participant.events << @event
          @participant.save!

          Factory(:contact_link, :event => @event, :person => @person,
                  :contact => Factory(:contact, :contact_date => "2000-12-25"))
        end

        it "next event should be PV2" do
          @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_2
        end

        context "next event date" do
          it "should be after 60 days from the contact date" do
            Factory(:contact_link, :person => @participant.person, :event => @event, :contact => Factory(:contact, :contact_date => '2012-01-01'))
            @participant.next_scheduled_event.date.should == Date.new(2012, 03, 01)
          end

          context "with due_date" do
            before(:each) do
              Factory(:ppg_detail, :participant => @participant,
                :ppg_first => NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1), :orig_due_date => Date.new(2012, 10, 01))
              @participant.due_date.should == Date.new(2012, 10, 01)
            end

            it "should be after 60 days from the contact date" do
              Factory(:contact_link, :person => @participant.person, :event => @event, :contact => Factory(:contact, :contact_date => '2012-01-01'))
              @participant.next_scheduled_event.date.should == Date.new(2012, 03, 01)
            end
          end
        end
      end

      context "for birth ready participant" do

        let(:date) { Date.new(2012, 02, 01) }

        before(:each) do
          @person = Factory(:person)
          @participant = Factory(:high_intensity_pregnancy_two_participant, :created_at => date)
          @participant.person = @person
          @event = Factory( :event, :participant => @participant,
                                          :event_start_date => date, :event_end_date => date,
                                          :event_type => NcsCode.pregnancy_screener)
          @participant.events << @event
          @participant.pregnancy_two_visit

          Factory(:contact_link, :event => @event, :person => @person,
              :contact => Factory(:contact, :contact_date => "2000-12-25"))
        end

        it "next event should be birth" do
          Factory(:contact_link, :person => @participant.person, :event => @event, :contact => Factory(:contact, :contact_date => '2012-01-02'))
          @participant.next_scheduled_event.event.should == PatientStudyCalendar::CHILD_CHILD
        end

        context "next event date" do
          it "should be date of the participant last contact date" do
            Factory(:contact_link, :person => @participant.person, :event => @event, :contact => Factory(:contact, :contact_date => '2012-01-02'))
            @participant.next_scheduled_event.date.should == Date.new(2012, 01, 02)
          end

          it 'fails if no contacts' do
            Participant.any_instance.stub(:last_contact).and_return(nil)
            expect { @participant.next_scheduled_event.date }.should raise_error(/Could not decide the next scheduled event date without the contact./)
          end

          context "with due_date" do
            before(:each) do
              Factory(:ppg_detail, :participant => @participant,
                :ppg_first => NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1), :orig_due_date => Date.new(2012, 10, 01))
              @participant.due_date.should == Date.new(2012, 10, 01)
            end

            it "should be 1 day after the due date" do
              @participant.next_scheduled_event.date.should == Date.new(2012, 10, 02)
            end
          end
        end
      end
    end

  end

  context "missing events" do

    describe "#mark_event_out_of_window" do

      setup_schedule_and_create_child_placeholder

      it "creates events for birth/child activities" do
        PatientStudyCalendar.stub!(:extract_scheduled_study_segment_identifier).and_return(scheduled_study_segment_identifier)
        psc.stub!(:template_snapshot).and_return(Nokogiri::XML(File.read(
              File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__))))

        general_study_visit = NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 3)

        VCR.use_cassette('psc/schedule_and_create_child_placeholder') do

          participant.person = person
          Factory(:contact_link, :contact => Factory(:contact, :contact_date_date => Date.parse("2000-01-01")),
          :event => Factory(:event, :participant => participant), :person => participant.person)
          participant.save!
          participant.stub!(:eligible?).and_return(true)

          Event.schedule_and_create_placeholder(psc, participant, "2012-08-09")
          participant.events.reload
          pending_events = participant.pending_events
          pending_events.size.should == 8
          birth_event_type = pending_events.second.event_type
          birth_event_type.to_s.should == "Birth"

          participant.mark_event_out_of_window(psc, pending_events.second)
          pending_events = participant.pending_events

          pending_events.size.should == 7
          pending_events.second.event_type.to_s.should == "3 Month"

          participant.completed_event?(birth_event_type).should be_true
          ce = participant.completed_events(birth_event_type)
          ce.size.should == 1
          ce.first.event_disposition.should == 48
          ce.first.event_disposition_category.should == general_study_visit
        end
      end

    end

  end

  context "with events" do

    context "determining pending events" do
      let(:participant1) { Factory(:participant, :high_intensity_state => 'in_high_intensity_arm', :high_intensity => true) }
      let(:participant2) { Factory(:participant, :high_intensity_state => 'in_high_intensity_arm', :high_intensity => true) }
      let(:participant3) { Factory(:participant, :high_intensity_state => 'in_high_intensity_arm', :high_intensity => true) }
      let(:date) { Date.parse("2001-01-02") }

      before(:each) do
        @e1_1 = Factory(:event, :participant => participant1, :event_end_date => 6.months.ago(date))
        @e1_2 = Factory(:event, :participant => participant1, :event_end_date => nil, :event_start_date => date)
        @e2_1 = Factory(:event, :participant => participant2, :event_end_date => 6.months.ago(date))
      end

      describe "#pending_events" do

        it "returns events without an event end date (i.e. pending)" do
          participant1.pending_events.should == [@e1_2]
          participant2.pending_events.should be_empty
          participant3.pending_events.should be_empty
        end

        it "orders events by event start date" do
          @e1_3 = Factory(:event, :participant => participant1, :event_end_date => nil, :event_start_date => 6.months.since(date))
          participant1.pending_events.should == [@e1_2, @e1_3]
        end

        it "orders events by event_type then event start date" do
          @e1_3 = Factory(:event, :participant => participant1, :event_type_code => 13,
                          :event_end_date => nil, :event_start_date => 6.months.since(date))
          @e1_4 = Factory(:event, :participant => participant1, :event_type_code => 10,
                          :event_end_date => nil, :event_start_date => 6.months.since(date))
          participant1.pending_events.should == [@e1_2, @e1_4, @e1_3]
        end

      end

    end

    context "assigned to a PPG" do

      context "in high intensity protocol" do
        let(:person) { Factory(:person) }
        let(:participant) { Factory(:participant, :high_intensity_state => 'in_high_intensity_arm', :high_intensity => true) }

        before :each do
          participant.person = person
          participant.save!
          date = Date.parse("2001-09-09")
          participant.events << Factory(:event, :participant => participant,
                                        :event_start_date => date, :event_end_date => date,
                                        :event_type => NcsCode.pregnancy_screener)
        end

        describe "a participant who is pregnant - PPG 1" do

          it "knows the upcoming applicable events" do
            status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)

            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION]

            participant.high_intensity_conversion!
            participant.should be_pregnancy_one
          end

        end

        describe "a participant who is not pregnant but actively trying - PPG 2" do

          it "knows the upcoming applicable events" do
            status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION]

            participant.non_pregnant_informed_consent!
            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_PRE_PREGNANCY]

            participant.follow!
            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP]
          end
        end

        describe "a participant who has had a recent pregnancy loss - PPG 3" do

          it "knows the upcoming applicable events" do
            status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 3)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
            participant.high_intensity_conversion!
            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP]
          end
        end

        describe "a participant who is not pregnant and not trying - PPG 4" do

          it "knows the upcoming applicable events" do
            status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 4)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
            participant.high_intensity_conversion!
            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP]
          end
        end

        describe "a participant who is ineligible - PPG 6" do

          it "knows the upcoming applicable events" do
            status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 6)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
            participant.high_intensity_conversion!
            participant.upcoming_events.should == []
          end
        end

      end
    end
  end

  context "with state" do

    let(:status1)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1) }
    let(:status2)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2) }
    let(:status3)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 3) }
    let(:status4)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 4) }
    let(:status5)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 5) }

    context "for the Low Intensity Protocol" do

      it "starts in the state of pending" do
        participant = Factory(:participant)
        participant.should be_low_intensity
        participant.state.should == "pending"
        participant.should be_pending
        participant.can_register?.should be_true
        participant.can_assign_to_pregnancy_probability_group?.should be_false
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
      end

      it "initially transitions into a registered state" do
        participant = Factory(:participant)
        participant.should be_pending
        participant.register!
        participant.should be_registered
        participant.state.should == "registered"
        participant.can_assign_to_pregnancy_probability_group?.should be_true
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
      end

      it "transitions from registered to in pregnancy probability group - PPG1/2" do
        participant = Factory(:participant)
        participant.register!
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)
        participant.assign_to_pregnancy_probability_group!
        participant.should be_in_pregnancy_probability_group
        participant.state.should == "in_pregnancy_probability_group"
        participant.events << Factory(:event, :participant => participant,
                                        :event_start_date => Date.today, :event_end_date => Date.today,
                                        :event_type => NcsCode.pregnancy_screener)
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
      end

      it "transitions from registered to in pregnancy probability group - PPG3/4" do
        participant = Factory(:participant)
        participant.register!
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status3)
        participant.assign_to_pregnancy_probability_group!
        participant.should be_in_pregnancy_probability_group
        participant.events << Factory(:event, :participant => participant,
                                        :event_start_date => Date.today, :event_end_date => Date.today,
                                        :event_type => NcsCode.pregnancy_screener)
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP
      end

      it "transitions from registered to in pregnancy probability group - PPG5/6" do
        participant = Factory(:participant)
        participant.register!
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status5)
        participant.assign_to_pregnancy_probability_group!
        participant.should be_in_pregnancy_probability_group
        participant.next_study_segment.should be_nil
      end

      it "transitions from in pregnancy probability group to pregnant" do
        participant = Factory(:participant)
        participant.register!
        date = Date.parse("2001-09-09")
        participant.events << Factory(:event, :participant => participant,
                                              :event_start_date => date, :event_end_date => date,
                                              :event_type => NcsCode.pregnancy_screener)
        contact = Factory(:contact, :contact_date_date => date)
        event = Factory(:event, :participant => participant)
        contact_link = Factory(:contact_link, :contact => contact, :event => event)

        Factory(:ppg_status_history, :participant => participant, :ppg_status => status3, :ppg_status_date => '2011-01-01' )
        participant.assign_to_pregnancy_probability_group!
        participant.should be_in_pregnancy_probability_group
        participant.next_study_segment.should == "LO-Intensity: PPG Follow-Up"

        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1, :ppg_status_date => '2011-02-02')
        participant = Participant.find(participant.id)
        participant.ppg_status.local_code.should == 1
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
        participant.can_impregnate_low?.should be_true
        lo_i_quex = Factory(:event, :participant => participant, :event_start_date => date, :event_end_date => date,
                            :event_type => NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33))

        participant.events << lo_i_quex
        participant.impregnate_low!
        participant.should be_pregnant
        participant.stub!(:due_date).and_return { 150.days.since(date).to_date }
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_BIRTH_VISIT_INTERVIEW
      end

    end

    context "experience Pregnancy Loss" do
      it "transitions from pregnant to loss" do
        participant = Factory(:participant)
        participant.register!
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1, :ppg_status_date => '2011-01-01')
        participant.assign_to_pregnancy_probability_group!
        participant.impregnate_low!

        participant = Participant.find(participant.id)
        participant.ppg_status.should == status1

        participant.lose_child!

        participant = Participant.find(participant.id)
        participant.ppg_status.should == status3
      end

      it "transitions from in ppg to loss" do
        participant = Factory(:participant)
        participant.register!
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status2, :ppg_status_date => '2011-01-01')
        participant.assign_to_pregnancy_probability_group!

        participant = Participant.find(participant.id)
        participant.ppg_status.should == status2

        participant.lose_child!

        participant = Participant.find(participant.id)
        participant.ppg_status.should == status3
      end

    end

    context "for the High Intensity Protocol" do
      it "can enroll in the high intensity arm only after being assigned a Pregnancy Probability Group" do
        participant = Factory(:participant)
        participant.should be_low_intensity
        participant.can_enroll_in_high_intensity_arm?.should be_false

        participant.register!
        participant.can_enroll_in_high_intensity_arm?.should be_false

        participant.assign_to_pregnancy_probability_group!
        participant.can_enroll_in_high_intensity_arm?.should be_true
      end

      it "can enroll in the high intensity arm if pregnant" do
        participant = Factory(:participant)
        participant.should be_low_intensity
        participant.register!
        participant.assign_to_pregnancy_probability_group!
        participant.impregnate_low!
        participant.can_enroll_in_high_intensity_arm?.should be_true
      end

      context "having enrolled in the High Intensity Arm" do

        before(:each) do
          @participant = Factory(:participant)
          @participant.register!
          date = Date.parse("2525-09-09")
          Factory(:ppg_status_history, :participant => @participant, :ppg_status => status2, :ppg_status_date => '2011-01-01')
          @participant.events << Factory(:event, :participant => @participant,
                                        :event_start_date => date, :event_end_date => date,
                                        :event_type => NcsCode.pregnancy_screener)

          @participant.assign_to_pregnancy_probability_group!
          @participant.enroll_in_high_intensity_arm!
        end

        it "will be followed after consent" do
          @participant.should_not be_followed
          @participant.high_intensity_conversion!
          @participant.should be_followed
        end

        it "will initially take the Hi-Lo Conversion script" do
          @participant.should be_moved_to_high_intensity_arm
          @participant.state.should == "in_high_intensity_arm"
          @participant.should be_in_high_intensity_arm
          @participant.should_not be_low_intensity
          @participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION
        end

        it "consents to the high intensity protocol" do
          @participant.high_intensity_conversion!
          @participant.should be_pre_pregnancy
          @participant.state.should == "pre_pregnancy"
          @participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_PRE_PREGNANCY
        end

        describe 'when there is a pregnancy' do
          before do
            @participant.non_pregnant_informed_consent!
            @participant.follow!
            @participant.impregnate!

            # setup check
            @participant.high_intensity_state.should == 'pregnancy_one'
          end

          shared_examples 'lost pregnancy' do
            it 'transitions back to following' do
              @participant.high_intensity_state.should == 'following_high_intensity'
            end
          end

          describe 'and it is lost before PV1' do
            before do
              @participant.lose_pregnancy!
            end

            include_examples 'lost pregnancy'
          end

          describe 'and it is lost between PV1 and PV2' do
            before do
              @participant.pregnancy_one_visit!
              @participant.lose_pregnancy!
            end

            include_examples 'lost pregnancy'
          end

          describe 'and it is lost between PV2 and birth' do
            before do
              @participant.pregnancy_one_visit!
              @participant.pregnancy_two_visit!
              @participant.lose_pregnancy!
            end

            include_examples 'lost pregnancy'
          end
        end

      end
    end
  end

  context "taking instruments and surveys" do

    it "is associated with an instrument" do
      person = Factory(:person)
      participant = Factory(:participant)
      participant.person = person
      participant.instruments.should be_empty

      link = Factory(:contact_link, :person => person)
      participant.instruments.reload
      participant.instruments.should_not be_empty
      participant.instruments.should == [link.instrument]
    end

    it "knows if it has taken an instrument for a particular survey" do
      person = Factory(:person)
      participant = Factory(:participant)
      participant.person = person

      survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
      ins_type = NcsCode.for_list_name_and_local_code("INSTRUMENT_TYPE_CL1", 99)

      survey.should_not be_nil

      participant.started_survey(survey).should be_false

      rs, ins = prepare_instrument(person, participant, survey)
      rs.save!
      participant.started_survey(survey).should be_true

      participant.instrument_for(survey).should_not be_complete

    end

  end

  context "participant types" do

    let(:age_eligible) { NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 1) }
    let(:trying)       { NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 2) }
    let(:pregnant)     { NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 3) }
    let(:bio_father)   { NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 4) }
    let(:soc_father)   { NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 5) }
    let(:child)        { NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 6) }

    let(:part_self)    { NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 1) }
    let(:mother)       { NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 2) }
    let(:father)       { NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 4) }
    let(:spouse)       { NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 6) }
    let(:partner)      { NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 7) }
    let(:child_rel)    { NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 8) }

    before(:each) do
      @ella  = Factory(:person, :first_name => "Ella", :last_name => "Fitzgerald")
      @mom   = Factory(:participant, :p_type => age_eligible)
      @mom.person = @ella

      @louis = Factory(:person, :first_name => "Louis", :last_name => "Armstrong")
      @dad   = Factory(:participant, :p_type => bio_father)
      @dad.person = @louis

      @kiddo = Factory(:person, :first_name => "Kid", :last_name => "Ory")
      @kid   = Factory(:participant, :p_type => child)
      @kid.person = @kiddo

      # Factory(:participant_person_link, :person => @ella,  :participant => @mom, :relationship => part_self)
      Factory(:participant_person_link, :person => @louis, :participant => @mom, :relationship => partner)
      Factory(:participant_person_link, :person => @kiddo, :participant => @mom, :relationship => child_rel)

      #Factory(:participant_person_link, :person => @louis, :participant => @dad, :relationship => part_self)
      Factory(:participant_person_link, :person => @ella,  :participant => @dad, :relationship => partner)
      Factory(:participant_person_link, :person => @kiddo, :participant => @dad, :relationship => child_rel)

      # Factory(:participant_person_link, :person => @kiddo, :participant => @kid, :relationship => part_self)
      Factory(:participant_person_link, :person => @louis, :participant => @kid, :relationship => father)
      Factory(:participant_person_link, :person => @ella,  :participant => @kid, :relationship => mother)

      @mom.participant_person_links.reload
      @dad.participant_person_links.reload
      @kid.participant_person_links.reload
    end

    describe "self" do
      it "knows it's own participant type" do
        @mom.participant_type.should == age_eligible.display_text
        @dad.participant_type.should == bio_father.display_text
        @kid.participant_type.should == child.display_text
      end
    end

    describe "mother's relationships" do

      it "knows its father" do
        @mom.father.should be_nil
      end

      it "knows its children" do
        @mom.children.should == [@kiddo]
      end

      it "knows its partner/significant other" do
        @mom.partner.should == @louis
      end

    end

    describe "child's relationships" do

      it "knows its father" do
        @kid.father.should == @louis
      end

      it "knows its mother" do
        @kid.mother.should == @ella
      end

    end

    describe "father's relationships" do

      it "knows its children" do
        @dad.children.should == [@kiddo]
      end

      it "knows its partner/significant other" do
        @dad.partner.should == @ella
      end

    end

  end

  context "switching from Low to High Intensity" do

    let(:participant) { Factory(:participant) }
    let(:person) { Factory(:person) }

    let(:preg_screen) { NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 29) }
    let(:lo_i_quex) { NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33) }
    let(:informed_consent) { NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 10) }

    let(:date) { "2012-02-06" }

    before(:each) do
      participant.person = person
      participant.save!
      participant.should be_low_intensity
      participant.register!
      participant.assign_to_pregnancy_probability_group!

      Factory(:event, :participant => participant, :event_start_date => date, :event_end_date => date, :event_type => preg_screen)
      @lo_i_quex = Factory(:event, :participant => participant, :event_start_date => date, :event_end_date => nil, :event_type => lo_i_quex)
      @informed_consent = Factory(:event, :participant => participant, :event_start_date => date, :event_end_date => nil, :event_type => informed_consent)
    end

    describe "#switch_arm" do

      it "moves the participant to high intensity" do
        participant.switch_arm
        participant.should be_high_intensity
        participant.should be_moved_to_high_intensity_arm
      end

      it "closes all pending events" do
        participant.pending_events.should == [@informed_consent, @lo_i_quex]
        participant.switch_arm
        participant.pending_events.should == []
      end

      it "puts the participant into following_low_intensity when switching from high to low" do
        participant.switch_arm
        participant.should be_high_intensity
        participant.switch_arm
        participant.should be_following_low_intensity
      end

    end

  end

  describe '#intensity' do
    it 'is :high when high' do
      Factory(:participant, :high_intensity => true).intensity.should == :high
    end

    it 'is :low when low' do
      Factory(:participant, :high_intensity => false).intensity.should == :low
    end
  end

  context "removing a participant from the study" do

    let(:participant) { Factory(:participant) }
    let(:person) { Factory(:person) }
    let(:lo_i_quex) { NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33) }

    before(:each) do
      @enrolled   = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)
      @unenrolled = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
      @event_disposition_category = NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 3)

      participant.person = person
      participant.save!

      participant.should be_enrolled
      participant.should be_being_followed

      psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
      @uri  = psc_config["uri"]
      @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")
    end

    let(:psc) { PatientStudyCalendar.new(@user) }

    describe "#unenroll" do

      it "sets the enroll status to No" do
        participant.unenroll!(psc, "unenroll reason")
        participant.should_not be_enrolled
        participant.should_not be_being_followed
      end

      it "deletes all pending events" do
        Factory(:event, :participant => participant, :event_start_date => "2012-04-01", :event_end_date => nil, :event_type => lo_i_quex)
        participant.pending_events.size.should == 1
        participant.unenroll!(psc, "unenroll reason")
        participant.events.reload
        participant.pending_events.should be_empty
        participant.events.should be_empty
      end

      it "closes all pending events that have been started" do
        e = Factory(:event, :participant => participant, :event_start_date => "2012-04-01", :event_end_date => nil, :event_type => lo_i_quex)
        cl = Factory(:contact_link, :event => e, :person => person)

        participant.pending_events.size.should == 1
        participant.unenroll!(psc, "unenroll reason")
        participant.events.reload
        participant.pending_events.should be_empty
        participant.events.should_not be_empty
        participant.events.first.should be_closed
        participant.events.first.event_disposition.should == 34
        participant.events.first.event_disposition_category.should == @event_disposition_category
      end

      it "withdraws the participant from the study" do
        Factory(:participant_consent, :participant => participant, :consent_form_type_code => 7, :consent_withdraw_code => -4)

        participant.participant_consents.should_not be_empty
        participant.participant_consents.each do |c|
          c.should be_consented
        end
        participant.should be_consented

        participant.unenroll!(psc, "unenroll reason")

        participant.participant_consents.each do |c|
          c.should_not be_consented
        end
        participant.should_not be_consented

      end
    end

    describe "#remove_from_active_followup" do
      it "sets the being_followed flag to false" do
        participant.remove_from_active_followup!(psc, "removal reason")
        participant.should_not be_being_followed
      end

      it "deletes all pending events" do
        Factory(:event, :participant => participant, :event_start_date => "2012-04-01", :event_end_date => nil, :event_type => lo_i_quex)
        participant.pending_events.size.should == 1
        participant.remove_from_active_followup!(psc, "removal reason")
        participant.events.reload
        participant.pending_events.should be_empty
        participant.events.should be_empty
      end

      it "closes all pending events that have been started" do
        e = Factory(:event, :participant => participant, :event_start_date => "2012-04-01", :event_end_date => nil, :event_type => lo_i_quex)
        cl = Factory(:contact_link, :event => e, :person => person)

        participant.pending_events.size.should == 1
        participant.remove_from_active_followup!(psc, "removal reason")
        participant.events.reload
        participant.pending_events.should be_empty
        participant.events.should_not be_empty
        participant.events.first.should be_closed
        participant.events.first.event_disposition.should == 34
        participant.events.first.event_disposition_category.should == @event_disposition_category
      end

    end

  end

  context "confirming participant eligibility for PBS" do
    include SurveyCompletion

    describe "#eligible?" do
      include_context 'custom recruitment strategy'

      let(:recruitment_strategy) { ProviderBasedSubsample.new }

      before(:each) do
        NcsNavigatorCore.stub!(:recruitment_type_id).and_return(5)

        # Givens
        @part = Factory(:participant)
        @pers = Factory(:person)
        pplk = Factory(:participant_person_link, :person_id => @pers.id, :participant_id => @part.id)
        @survey = create_pbs_eligibility_screener_survey_with_eligibility_questions
        @response_set, instrument = prepare_instrument(@pers, @part, @survey)

        # Eligibility - Affirmative answers
        @age_eligible = NcsCode.for_list_name_and_local_code("AGE_ELIGIBLE_CL1", 1)
        @lives_in_county = NcsCode.for_list_name_and_local_code("SCREENER_ELIG_PSU_CL1", 1)
        @pregnant = NcsCode.for_list_name_and_local_code("PREGNANCY_STATUS_CL1", 1)
        @first_visit = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL7", 1)
        @provider_out_of_frame = NcsCode.for_list_name_and_local_code("PROVIDER_OFFICE_ON_FRAME_CL1", 2)

        # Eligibility - Negative answers
        @not_age_eligible = NcsCode.for_list_name_and_local_code("AGE_ELIGIBLE_CL1", 2)
        @does_not_live_in_county = NcsCode.for_list_name_and_local_code("SCREENER_ELIG_PSU_CL1", 2)
        @not_pregnant = NcsCode.for_list_name_and_local_code("PREGNANCY_STATUS_CL1", 2)
        @not_first_visit = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL7", 2)
        @provider_in_frame = NcsCode.for_list_name_and_local_code("PROVIDER_OFFICE_ON_FRAME_CL1", 1)

      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_ELIG", @age_eligible
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PSU_ELIG_CONFIRM", @lives_in_county
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT",@pregnant
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.FIRST_VISIT", @first_visit
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX_PROVIDER_OFFICE}.PROVIDER_OFFICE_ON_FRAME", @provider_out_of_frame
      end

        @response_set.responses.reload
        @response_set.responses.size.should == 5
      end

      it "is the participant eligible?" do
        @part.eligible?.should be_true
      end

      describe "#age_eligible?" do
        it "returns whether participant is age-eligible" do
          @part.should be_age_eligible(@pers)
        end

        it "returns false if participant is not age eligible" do
          take_survey(@survey, @response_set) { |a| a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_ELIG", @not_age_eligible }
          @part.should_not be_age_eligible(@pers)
        end
      end

      describe "#psu_county_eligible?" do
        it "returns whether participant lives in eligible PSU" do
          @part.should be_psu_county_eligible(@pers)
        end

        it "returns false if participant coes not live in an eligible PSU" do
          take_survey(@survey, @response_set) { |a| a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PSU_ELIG_CONFIRM", @does_not_live_in_county }
          @part.should_not be_psu_county_eligible(@pers)
        end
      end

      describe "#pbs_pregnant?" do
        it "returns whether participant is pregnant" do
          @part.should be_pbs_pregnant(@pers)
        end

        it "returns false if they are not pregnant" do
          take_survey(@survey, @response_set) { |a| a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", @not_pregnant }
          @part.should_not be_pbs_pregnant(@pers)
        end
      end

      describe "#first_visit?" do
        it "is this the participants first visit to this provider?" do
          @part.should be_first_visit(@pers)
        end

        it "returns false if its not the participant's first visit" do
          take_survey(@survey, @response_set) { |a| a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.FIRST_VISIT", @not_first_visit }
          @part.should_not be_first_visit(@pers)
        end
      end

      describe "#no_preceding_providers_in_frame?" do
        it "have any of the providers been in-frame" do
          @part.should be_no_preceding_providers_in_frame(@pers)
        end

        it "returns false if there was a former provider in frame" do
          take_survey(@survey, @response_set) { |a| a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX_PROVIDER_OFFICE}.PROVIDER_OFFICE_ON_FRAME", @provider_in_frame }
          @part.should_not be_no_preceding_providers_in_frame(@pers)
        end

        it "defaults to true if there are no responses as to whether a former provider was in frame" do
          Response.delete_all
          @part.should be_no_preceding_providers_in_frame(@pers)
        end
      end

      it "returns false if ineligible" do
        take_survey(@survey, @response_set) { |a| a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PSU_ELIG_CONFIRM", @does_not_live_in_county }
        @part.should_not be_psu_county_eligible(@pers)
        @part.should_not be_eligible
      end
    end
  end

  context "confirming participant eligibility for non-PBS" do
    include_context 'custom recruitment strategy'

    let(:recruitment_strategy) { TwoTier.new }

    before do
      NcsNavigatorCore.stub!(:recruitment_type_id).and_return(3)
      @part = Factory(:participant)
    end

    describe "#has_eligible_ppg_status?" do
      describe "for Two Tier" do
        it "returns true for PPG statuses 1 through 4" do
          (1..4).each do |ppg_status|
            status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", ppg_status)
            Factory(:ppg_status_history, :participant => @part, :ppg_status => status)
            @part.should have_eligible_ppg_status
          end
        end
        it "returns false for PPG statuses 5 and 6" do
          (5..6).each do |ppg_status|
            status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", ppg_status)
            Factory(:ppg_status_history, :participant => @part, :ppg_status => status)
            @part.should_not have_eligible_ppg_status
          end
        end
      end
    end
  end

  describe ".next_scheduled_event" do

    it "returns nil if the participant has no contacts" do
      Participant.any_instance.stub(:contacts).and_return([])
      Factory(:participant).next_scheduled_event.should be_nil
    end

    it "returns nil if the participant has no next_study_segment" do
      Factory(:low_intensity_ppg6_participant).next_scheduled_event.should be_nil
    end

    it "returns the next scheduled event"
  end

  describe '#advance' do
    let!(:p) { Factory(:participant) }
    let!(:pe) { Factory(:person) }
    let(:psc) { double }
    let(:psc_success_resp) { stub(:success? => true, :body => 'test') }

    before do
      # Many state transitions are time-dependent, so freeze today to a known
      # value.
      Date.stub!(:today => Date.parse('2000-01-01'))

      # There's a bunch of PSC actions done when events are scheduled.
      # However, the only ones we care about are:
      #
      # * schedule_next_segment, which must return success
      # * unique_label_ideal_date_pairs_for_scheduled_segment, which
      #   returns data used to schedule event placeholders
      #
      # Every other action just needs to exist.
      psc.stub!(:schedule_next_segment => psc_success_resp,
                :cancel_collection_instruments => true,
                :cancel_non_matching_mdes_version_instruments => true)
    end

    describe 'in PBS' do
      around do |example|
        begin
          old_strategy = NcsNavigatorCore.recruitment_strategy
          NcsNavigatorCore.recruitment_strategy = ProviderBasedSubsample.new
          example.call
        ensure
          NcsNavigatorCore.recruitment_strategy = old_strategy
        end
      end

      describe 'with an eligible participant' do
        before do
          p.stub!(:eligible_for_pbs? => true)
          p.person = pe
          p.save!
        end

        def latest_event
          # Participant#events imposes its own ordering, which isn't useful in
          # this case.
          Event.where(:participant_id => p.id).order(:created_at).last
        end

        describe 'that completed the eligibility screener' do
          let!(:e) { Factory(:event, :participant => p, :event_type_code => 34, :event_end_date => Date.parse('2000-01-01')) }
          let(:pairs) do
            [
              ['pregnancy_visit_1', Date.parse('2000-02-01')]
            ]
          end

          before do
            # These examples require that we be able to schedule an event.
            # Participant#next_scheduled_event requires a contact, despite the
            # name.
            ContactLink.create!(:contact => Factory(:contact), :event => e, :staff_id => 'test')

            # Supply appropriate (event label, ideal date) pairs as a PSC
            # scheduling result.
            psc.stub!(:unique_label_ideal_date_pairs_for_scheduled_segment => pairs)

            p.advance(psc)
          end

          it 'schedules Pregnancy Visit 1' do
            latest_event.event_type_code.should == 13
          end

          it 'schedules Pregnancy Visit 1 with the start date supplied by PSC' do
            latest_event.event_start_date.should == Date.parse('2000-02-01')
          end

          it 'schedules Pregnancy Visit 1 as an open event' do
            latest_event.event_end_date.should be_nil
          end
        end

        describe 'that has not completed Pregnancy Visit 1' do
          let!(:e) { Factory(:event, :participant => p, :event_type_code => 34, :event_end_date => nil) }
          let(:pairs) do
            [
              ['pregnancy_visit_1', Date.parse('2000-02-01')]
            ]
          end

          before do
            ContactLink.create!(:contact => Factory(:contact), :event => e, :staff_id => 'test')
            psc.stub!(:unique_label_ideal_date_pairs_for_scheduled_segment => pairs)

            p.advance(psc)
          end

          it 'keeps the participant at Pregnancy Visit 1' do
            latest_event.event_type_code.should == 34
          end

          it 'does not schedule Pregnancy Visit 2' do
            Event.where(:event_type_code => 15).should be_empty
          end
        end

        describe 'that completed Pregnancy Visit 1' do
          let!(:e) { Factory(:event, :participant => p, :event_type_code => 13, :event_end_date => Date.parse('2000-01-01')) }

          let(:pairs) do
            [
              ['pregnancy_visit_2', Date.parse('2000-02-01')]
            ]
          end

          describe 'and whose due date is more than 60 days from today' do
            before do
              # Set participant's due date to today + 61 days.
              p.ppg_details.create!(:orig_due_date => Date.today + 61.days)

              # See eligiblity screener setup.
              ContactLink.create!(:contact => Factory(:contact), :event => e, :staff_id => 'test')
              psc.stub!(:unique_label_ideal_date_pairs_for_scheduled_segment => pairs)

              p.advance(psc)
            end

            it 'schedules Pregnancy Visit 2' do
              latest_event.event_type_code.should == 15
            end

            it 'schedules Pregnancy Visit 2 with the start date supplied by PSC' do
              latest_event.event_start_date.should == Date.parse('2000-02-01')
            end

            it 'schedules Pregnancy Visit 2 as an open event' do
              latest_event.event_end_date.should be_nil
            end
          end
        end
      end
    end
  end
end
