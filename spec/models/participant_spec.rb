# == Schema Information
# Schema version: 20120321181032
#
# Table name: participants
#
#  id                       :integer         not null, primary key
#  psu_code                 :integer         not null
#  p_id                     :string(36)      not null
#  p_type_code              :integer         not null
#  p_type_other             :string(255)
#  status_info_source_code  :integer         not null
#  status_info_source_other :string(255)
#  status_info_mode_code    :integer         not null
#  status_info_mode_other   :string(255)
#  status_info_date         :date
#  enroll_status_code       :integer         not null
#  enroll_date              :date
#  pid_entry_code           :integer         not null
#  pid_entry_other          :string(255)
#  pid_age_eligibility_code :integer         not null
#  pid_comment              :text
#  transaction_type         :string(36)
#  created_at               :datetime
#  updated_at               :datetime
#  being_processed          :boolean
#  high_intensity           :boolean
#  low_intensity_state      :string(255)
#  high_intensity_state     :string(255)
#

require 'spec_helper'

describe Participant do

  before(:each) do
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
  end

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
  it { should have_many(:events) }

  it { should have_many(:low_intensity_state_transition_audits) }
  it { should have_many(:high_intensity_state_transition_audits) }

  it { should have_many(:participant_consents) }

  # it { should validate_presence_of(:person) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pr = Factory(:participant)
      pr.public_id.should_not be_nil
      pr.p_id.should == pr.public_id
      pr.p_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Participant)

      pr = Participant.create
      pr.psu = Factory(:ncs_code)
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
          arr_of_arrs = FasterCSV.parse(csv)

          arr_of_arrs[0][0].should == "When"
          arr_of_arrs[0][22].should == "Enroll Date"
          arr_of_arrs[1][22].should == Date.today.to_s(:db)
          arr_of_arrs[2][22].should == "2012-02-25"
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
    let(:expected_due_date) { 6.months.from_now.strftime('%Y-%m-%d') }

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
    let(:status1)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
    let(:status2)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }
    let(:status2a) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }

    let(:status3)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3) }
    let(:status4)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4: Other Probability – Not Pregnancy and not Trying", :local_code => 4) }

    it "determines the ppg from the ppg_details if there is no ppg_status_history record" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a)

      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should be_empty
      participant.ppg_status.should == status2a
    end

    it "determines the ppg from the ppg_status_history" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a)
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)

      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should_not be_empty
      participant.ppg_status.should == status1
    end

    it "determines the ppg from the most recent ppg_status_history" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a)
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status2,  :ppg_status_date => '2011-01-02')
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status1, :ppg_status_date => '2011-01-31')

      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should_not be_empty
      participant.ppg_status.should == status1
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

    let(:ppg1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 1: Pregnant", :local_code => 1) }
    let(:ppg3) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3) }

    before(:each) do

      person1 = Factory(:person)
      participant1 = Factory(:participant, :high_intensity => true)
      participant1.person = person1
      Factory(:ppg_detail, :participant => participant1, :ppg_first => ppg1)

      person2 = Factory(:person)
      participant2 = Factory(:participant, :high_intensity => true)
      participant2.person = person2
      Factory(:ppg_detail, :orig_due_date => 3.months.from_now.strftime('%Y-%m-%d'), :participant => participant2, :ppg_first => ppg1)
    end

    it "returns all participants with an upcoming due date" do
      Participant.count.should == 2
      Participant.upcoming_births.count.should == 1
    end

  end

  context "when determining schedule" do

    describe "a participant who has had a recent pregnancy loss (PPG 3)" do

      before(:each) do
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3)
        person = Factory(:person)
        @participant = Factory(:participant, :high_intensity => true)
        @participant.person = person
        @participant.register!
        @participant.assign_to_pregnancy_probability_group!
        Factory(:ppg_status_history, :participant => @participant, :ppg_status => status)
      end

      it "knows the upcoming applicable events when a new record" do
        @participant.ppg_status.local_code.should == 3

        @participant.high_intensity_conversion!
        @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        @participant.next_scheduled_event.date.should == 6.months.from_now.to_date
      end

      it "knows the upcoming applicable events who has had a followup already" do
        event_type = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Probability", :local_code => 7)
        event_disposition_category = Factory(:ncs_code, :list_name => "EVENT_DSPSTN_CAT_CL1",  :display_text => "Telephone Interview Events", :local_code => 5)
        event = Factory(:event, :event_type => event_type, :event_disposition_category => event_disposition_category)
        contact = Factory(:contact)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 5.months.ago, :contact => contact)

        @participant.high_intensity_conversion!

        @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        @participant.next_scheduled_event.date.should == 1.month.from_now.to_date
      end

      it "knows the upcoming applicable events who has had several followups already" do
        event_type = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Probability", :local_code => 7)
        event_disposition_category = Factory(:ncs_code, :list_name => "EVENT_DSPSTN_CAT_CL1",  :display_text => "Telephone Interview Events", :local_code => 5)
        event = Factory(:event, :event_type => event_type, :event_disposition_category => event_disposition_category)

        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 10.month.ago)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 7.month.ago)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 4.month.ago)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 1.month.ago)

        @participant.high_intensity_conversion!

        @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        @participant.next_scheduled_event.date.should == 5.month.from_now.to_date
      end
    end

    context "in the low intensity protocol" do

      it "knows the upcoming applicable events for a new participant" do
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2)
        person = Factory(:person)
        @participant = Factory(:participant, :high_intensity => false)
        @participant.person = person
        @participant.register!
        @participant.assign_to_pregnancy_probability_group!
        Factory(:ppg_status_history, :participant => @participant, :ppg_status => status)
        @participant.next_scheduled_event.event.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
        @participant.next_scheduled_event.date.should == Date.today
      end

    end

    context "in the high intensity protocol" do

      it "knows the upcoming applicable events for a consented participant" do
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2)
        person = Factory(:person)
        @participant = Factory(:participant, :high_intensity => true, :high_intensity_state => "converted_high_intensity")
        @participant.person = person
        @participant.register!
        @participant.assign_to_pregnancy_probability_group!
        Factory(:ppg_status_history, :participant => @participant, :ppg_status => status)
        @participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        @participant.next_scheduled_event.date.should == 3.months.from_now.to_date
      end

    end

  end

  context "with events" do

    context "determining pending events" do
      let(:participant1) { Factory(:participant, :high_intensity_state => 'in_high_intensity_arm', :high_intensity => true) }
      let(:participant2) { Factory(:participant, :high_intensity_state => 'in_high_intensity_arm', :high_intensity => true) }
      let(:participant3) { Factory(:participant, :high_intensity_state => 'in_high_intensity_arm', :high_intensity => true) }

      before(:each) do
        @e1_1 = Factory(:event, :participant => participant1, :event_end_date => 6.months.ago)
        @e1_2 = Factory(:event, :participant => participant1, :event_end_date => nil)
        @e2_1 = Factory(:event, :participant => participant2, :event_end_date => 6.months.ago)
      end

      describe "#pending_events" do

        it "returns events without an event end date (i.e. pending)" do
          participant1.pending_events.should == [@e1_2]
          participant2.pending_events.should be_empty
          participant3.pending_events.should be_empty
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
        end

        describe "a participant who is pregnant - PPG 1" do

          it "knows the upcoming applicable events" do
            status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)

            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION]

            participant.high_intensity_conversion!
            participant.should be_pregnancy_one
            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1]
            participant.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1
            participant.next_scheduled_event.date.should == Date.today
          end

        end

        describe "a participant who is not pregnant but actively trying - PPG 2" do

          it "knows the upcoming applicable events" do
            status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2)
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
            status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
            participant.high_intensity_conversion!
            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP]
          end
        end

        describe "a participant who is not pregnant and not trying - PPG 4" do

          it "knows the upcoming applicable events" do
            status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4: Other Probability – Not Pregnancy and not Trying", :local_code => 4)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
            participant.high_intensity_conversion!
            participant.upcoming_events.should == [PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP]
          end
        end

        describe "a participant who is ineligible - PPG 6" do

          it "knows the upcoming applicable events" do
            status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 6: Withdrawn", :local_code => 6)
            Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
            participant.high_intensity_conversion!
            participant.upcoming_events.should == []
          end
        end

      end
    end
  end

  context "with state" do

    let(:status1)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
    let(:status2)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }
    let(:status3)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3) }
    let(:status4)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4: Other Probability – Not Pregnancy and not Trying", :local_code => 4) }
    let(:status5)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 5: Ineligible", :local_code => 5) }

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
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
      end

      it "transitions from registered to in pregnancy probability group - PPG3/4" do
        participant = Factory(:participant)
        participant.register!
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status3)
        participant.assign_to_pregnancy_probability_group!
        participant.should be_in_pregnancy_probability_group
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
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status3, :ppg_status_date => '2011-01-01' )
        participant.assign_to_pregnancy_probability_group!
        participant.should be_in_pregnancy_probability_group
        participant.next_study_segment.should == "LO-Intensity: PPG Follow-Up"
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1, :ppg_status_date => '2011-02-02')
        participant = Participant.find(participant.id)
        participant.ppg_status.local_code.should == 1
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
        participant.can_impregnate_low?.should be_true

        participant.impregnate_low!
        participant.should be_pregnant
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_BIRTH_VISIT_INTERVIEW
      end

    end

    context "experience Pregnancy Loss" do
      before(:each) do
        if (NcsCode.where(:list_name => "PPG_STATUS_CL1").where(:local_code => 3).count == 0)
          Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3)
        end
        if (NcsCode.where(:list_name => "INFORMATION_SOURCE_CL3").where(:local_code => -5).count == 0)
          Factory(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :display_text => "Unknown", :local_code => -5)
        end
        if (NcsCode.where(:list_name => "CONTACT_TYPE_CL1").where(:local_code => -5).count == 0)
          Factory(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "Unknown", :local_code => -5)
        end
      end

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
          Factory(:ppg_status_history, :participant => @participant, :ppg_status => status2, :ppg_status_date => '2011-01-01')
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
      ins_type = Factory(:ncs_code, :list_name => "INSTRUMENT_TYPE_CL1", :display_text => "Pregnancy Screener", :local_code => 99)
      create_missing_in_error_ncs_codes(Instrument)

      survey.should_not be_nil

      participant.started_survey(survey).should be_false

      rs, ins = prepare_instrument(participant, survey)
      rs.save!
      participant.started_survey(survey).should be_true

      participant.instrument_for(survey).should_not be_complete

    end

  end

  context "participant types" do

    let(:age_eligible) { Factory(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "Age-eligible woman",      :local_code => 1) }
    let(:trying)       { Factory(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "High Trier",              :local_code => 2) }
    let(:pregnant)     { Factory(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "Pregnant eligible woman", :local_code => 3) }
    let(:bio_father)   { Factory(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "Biological Father",       :local_code => 4) }
    let(:soc_father)   { Factory(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "Social Father",           :local_code => 5) }
    let(:child)        { Factory(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "NCS Child",               :local_code => 6) }

    let(:part_self)    { Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Participant/Self",          :local_code => 1) }
    let(:mother)       { Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Biological Mother",         :local_code => 2) }
    let(:father)       { Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Biological Father",         :local_code => 4) }
    let(:spouse)       { Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Spouse",                    :local_code => 6) }
    let(:partner)      { Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Partner/Significant Other", :local_code => 7) }
    let(:child_rel)    { Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Child",                     :local_code => 8) }

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
        @mom.participant_type.should == "Age-eligible woman"
        @dad.participant_type.should == "Biological Father"
        @kid.participant_type.should == "NCS Child"
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

    let(:preg_screen) { Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Screener", :local_code => 29) }
    let(:lo_i_quex) { Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Low Intensity Data Collection", :local_code => 33) }
    let(:informed_consent) { Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Informed Consent", :local_code => 10) }

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
        participant.pending_events.should == [@lo_i_quex, @informed_consent]
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
end
