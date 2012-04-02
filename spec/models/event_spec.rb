# == Schema Information
# Schema version: 20120321181032
#
# Table name: events
#
#  id                                 :integer         not null, primary key
#  psu_code                           :integer         not null
#  event_id                           :string(36)      not null
#  participant_id                     :integer
#  event_type_code                    :integer         not null
#  event_type_other                   :string(255)
#  event_repeat_key                   :integer
#  event_disposition                  :integer
#  event_disposition_category_code    :integer         not null
#  event_start_date                   :date
#  event_start_time                   :string(255)
#  event_end_date                     :date
#  event_end_time                     :string(255)
#  event_breakoff_code                :integer         not null
#  event_incentive_type_code          :integer         not null
#  event_incentive_cash               :decimal(12, 2)
#  event_incentive_noncash            :string(255)
#  event_comment                      :text
#  transaction_type                   :string(255)
#  created_at                         :datetime
#  updated_at                         :datetime
#  scheduled_study_segment_identifier :string(255)
#

require 'spec_helper'

describe Event do

  it "should create a new instance given valid attributes" do
    e = Factory(:event)
    e.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:event_type) }
  it { should belong_to(:event_disposition_category) }
  it { should belong_to(:event_breakoff) }
  it { should belong_to(:event_incentive_type) }

  it { should have_many(:contact_links) }
  it { should have_many(:instruments).through(:contact_links) }

  describe '#closed?' do
    subject { Factory(:event) }

    describe 'if end date is not blank' do
      before do
        subject.event_end_date = Date.today
      end

      it 'is true' do
        subject.should be_closed
      end
    end

    describe 'if end date is blank' do
      before do
        subject.event_end_date = nil
      end

      it 'is false' do
        subject.should_not be_closed
      end
    end
  end

  describe ".import_sort_date" do

    it "returns the event start date if the event end date is null" do
      event = Factory(:event, :event_end_date => nil)
      event.import_sort_date.should == event.event_start_date
    end

    it "returns the event start date if the event end date is some variant of '9777-97-97'" do
      event = Factory(:event, :event_end_date => '9777-97-97')
      event.import_sort_date.should == event.event_start_date
    end

    it "returns the event end date if it exists and is valid" do
      event = Factory(:event, :event_end_date => Date.today)
      event.import_sort_date.should == event.event_end_date
    end

  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      e = Factory(:event)
      e.public_id.should_not be_nil
      e.event_id.should == e.public_id
      e.event_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Event)

      e = Event.new
      e.psu = Factory(:ncs_code)
      e.participant = Factory(:participant)
      e.save!

      obj = Event.first
      obj.event_type.local_code.should == -4
      obj.event_disposition_category.local_code.should == -4
      obj.event_breakoff.local_code.should == -4
      obj.event_incentive_type.local_code.should == -4
    end
  end

  context "human-readable attributes" do
    it "returns the event type display text for to_s" do
      e = Factory(:event)
      e.to_s.should == e.event_type.display_text
    end

    it "concatenates the start date and time for the event start" do
      e = Factory(:event)
      e.event_start.should == "N/A"
      e.event_start_time = "HH:MM"
      e.event_start_date = Date.parse('2011-01-01')
      e.event_start.should == "2011-01-01 HH:MM"
    end

    it "concatenates the end date and time for the event end" do
      e = Factory(:event)
      e.event_end.should == "N/A"
      e.event_end_date = Date.parse('2011-01-01')
      e.event_end_time = "HH:MM"
      e.event_end.should == "2011-01-01 HH:MM"
    end
  end

  context "disposition" do

    describe "household enumeration" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 1, :display_text => "Household Enumeration Events")
      end

      it "knows if it is complete" do
        (540..545).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 546, 539].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end

    end

    describe "pregnancy screener" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 2, :display_text => "Pregnancy Screening Events")
      end

      it "knows if it is complete" do
        (560..565).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 566, 559].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end

    end

    describe "general study" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 3, :display_text => "General Study Visits (including CASI SAQs)")
      end

      it "knows if it is complete" do
        (560..562).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 563, 559].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end

    end

    describe "mailed back saq" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 4, :display_text => "Mailed Back Self Administered Questionnaires")
      end

      it "knows if it is complete" do
        (550..556).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 549, 557].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end

    describe "telephone interview" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 5, :display_text => "Telephone Interview Events")
      end

      it "knows if it is complete" do
        (590..595).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 589, 596].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end

    describe "internet survey" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 6, :display_text => "Internet Survey Events")
      end

      it "knows if it is complete" do
        (540..546).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 539, 547].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end

  end

  describe '.TYPE_ORDER' do
    it 'has no duplicates' do
      Event::TYPE_ORDER.uniq.size.should == Event::TYPE_ORDER.size
    end

    it 'contains integers' do
      Event::TYPE_ORDER.collect(&:class).uniq.should == [Fixnum]
    end

    # TODO: don't hard-code the count
    it 'has an item for every event type' do
      Event::TYPE_ORDER.size.should == 35
    end
  end

  context "auto-completing MDES data" do

    before(:each) do
      create_missing_in_error_ncs_codes(Event)

      @person = Factory(:person)
      @participant = Factory(:participant)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
      @participant.person = @person
      @ppg_fu = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Pregnancy Probability", :local_code => 7)
      @preg_screen = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Pregnancy Screener", :local_code => 29)
      @hh = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Household Enumeration", :local_code => 1)

      [
        [1, "Household Enumeration Events"],
        [2, "Pregnancy Screening Events"],
        [3, "General Study Visits (including CASI SAQs)"],
        [4, "Mailed Back Self Administered Questionnaires"],
        [5, "Telephone Interview Events"],
        [6, "Internet Survey Events"]
      ].each do |local_code, display_text|
        Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :display_text => display_text, :local_code => local_code)
      end

      @telephone = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Telephone', :local_code => 3)
      @mail      = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Mail', :local_code => 2)
      @in_person = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'In-Person', :local_code => 1)
      @txtmsg    = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Text Message', :local_code => 5)
      @website   = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Website', :local_code => 6)

      @y = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "Yes", :local_code => 1)
      @n = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "No",  :local_code => 2)

    end

    describe "the disposition category" do

      it "is first determined by the event type" do
        event = Event.create(:participant => @participant, :event_type => @preg_screen, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes
        event.save!
        event.event_disposition_category.local_code.should == 2

        event = Event.create(:participant => @participant, :event_type => @hh, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes
        event.save!
        event.event_disposition_category.local_code.should == 1
      end

      it "is next determined by the contact type" do
        # telephone
        contact = Factory(:contact, :contact_type => @telephone)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 5

        # mail
        contact = Factory(:contact, :contact_type => @mail)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 4

        # txt
        contact = Factory(:contact, :contact_type => @txtmsg)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 6

        # website
        contact = Factory(:contact, :contact_type => @website)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 6

        # in person
        contact = Factory(:contact, :contact_type => @in_person)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 3

      end

    end
    # = f.text_field :event_repeat_key
    # = render "shared/disposition_code", { :f => f, :code => :event_disposition }

    describe "the breakoff code" do

      it "should set the breakoff code to no if the reponse set has questions answered" do
        response_set = Factory(:response_set)
        response_set.stub!(:has_responses_in_each_section_with_questions?).and_return(true)
        event = Event.create(:participant => @participant, :event_type => @preg_screen, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(nil, response_set)
        event.save!
        event.event_breakoff.should == @n
      end

      it "should set the breakoff code to yes if the reponse set does not have questions answered in each section" do
        response_set = Factory(:response_set)
        response_set.stub!(:has_responses_in_each_section_with_questions?).and_return(false)
        event = Event.create(:participant => @participant, :event_type => @preg_screen, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(nil, response_set)
        event.save!
        event.event_breakoff.should == @y
      end

    end

  end

  context "when scheduling an event with PSC " do

    before(:each) do
      create_missing_in_error_ncs_codes(Event)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
    end

    let(:scheduled_study_segment_identifier) { "a5fd83f9-e2ca-4481-8ce3-70406dfbcddc" }
    let(:event_type_code) { Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Low Intensity Data Collection", :local_code => 33) }
    let(:person) {Factory(:person, :first_name => "Jane", :last_name => "Doe", :person_dob => '1980-02-14', :person_id => "placeholder_event_participant")}
    let(:participant) { Factory(:participant, :p_id => "placeholder_event_participant") }
    let(:date) { "2012-02-06" }
    let(:xml) { %Q(<?xml version="1.0" encoding="UTF-8"?><scheduled-study-segment id="a5fd83f9-e2ca-4481-8ce3-70406dfbcddc"></scheduled-study-segment>) }
    let(:response_body) { Nokogiri::XML(xml) }

    describe "#create_placeholder_record" do

      it "creates an event record for the participant and event type associating the scheduled-study-segment" do

        Event.where(:scheduled_study_segment_identifier => scheduled_study_segment_identifier).count.should == 0
        event = Event.create_placeholder_record(participant, date, event_type_code, scheduled_study_segment_identifier)
        events = Event.where(:scheduled_study_segment_identifier => scheduled_study_segment_identifier).all
        events.count.should == 1
        events.first.should == event
        events.first.participant.should == participant

        participant.pending_events.should == events
      end

      it "does not need a parseable date to create a record" do
        Event.where(:scheduled_study_segment_identifier => scheduled_study_segment_identifier).count.should == 0
        event = Event.create_placeholder_record(participant, "date", event_type_code, scheduled_study_segment_identifier)
        events = Event.where(:scheduled_study_segment_identifier => scheduled_study_segment_identifier).all
        events.count.should == 1
      end

    end

    describe "#schedule_and_create_placeholder" do

      before(:each) do
        @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")
        create_all_event_types
      end

      let(:psc) { PatientStudyCalendar.new(@user) }
      let(:date) { "2012-02-06" }

      it "returns nil if there is no event to schedule" do
        part = Factory(:low_intensity_ppg5_participant)
        part.next_scheduled_event.should be_blank
        Event.schedule_and_create_placeholder(psc, part).should be_nil
      end

      it "creates events as for ppg followup activities" do

        PatientStudyCalendar.stub!(:extract_scheduled_study_segment_identifier).and_return("a5fd83f9-e2ca-4481-8ce3-70406dfbcddc")
        psc.stub!(:template_snapshot).and_return(Nokogiri::XML(File.read(
              File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__))))

        VCR.use_cassette('psc/schedule_and_create_placeholder') do

          participant.person = person
          participant.save!

          participant.events.should be_empty
          Event.schedule_and_create_placeholder(psc, participant, date)
          participant.events.reload
          participant.events.should_not be_empty
          participant.events.size.should == 2
          participant.events.each do |e|
            e.scheduled_study_segment_identifier.should == scheduled_study_segment_identifier
            e.event_start_date.to_s.should == date
          end
        end
      end

      it "cancels events for phase2 activities if configured to do so" do
        NcsNavigatorCore.with_specimens?.should be_false

        PatientStudyCalendar.stub!(:extract_scheduled_study_segment_identifier).and_return("f6abc107-a24e-4169-a260-d407fe816910")
        psc.stub!(:template_snapshot).and_return(Nokogiri::XML(File.read(
              File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__))))

        part = Factory(:high_intensity_pregnancy_one_participant)
        part.next_scheduled_event.event.should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1

        phase2person = Factory(:person, :first_name => "Francesca", :last_name => "Zupicich", :person_dob => '1980-02-14',
                              :person_id => "placeholder_phase2_participant")

        VCR.use_cassette('psc/schedule_and_create_phase2_placeholder') do

          part.person = phase2person
          part.save!

          Event.schedule_and_create_placeholder(psc, part, "2012-08-09")

          subject_schedule = psc.scheduled_activities(part)
          subject_schedule.size.should == 4

          subject_schedule.each do |s|
            s.study_segment.should == "HI-Intensity: Pregnancy Visit 1"
            s.ideal_date.should == "2012-08-09"
            s.current_state.should == PatientStudyCalendar::ACTIVITY_SCHEDULED
          end

        end

      end

    end
  end

  context "child events" do
    before(:each) do
      create_missing_in_error_ncs_codes(Event)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
    end
    describe "#schedule_and_create_placeholder" do

      let(:scheduled_study_segment_identifier) { "f699ac2e-9784-48b7-bfc6-229e54d233b7" }
      let(:person) {Factory(:person, :first_name => "Francesca", :last_name => "Zupicich", :person_dob => '1980-02-14',
                            :person_id => "placeholder_child_participant")}
      let(:participant) { Factory(:participant, :p_id => "placeholder_child_participant") }
      let(:xml) { %Q(<?xml version="1.0" encoding="UTF-8"?><scheduled-study-segment id="a5fd83f9-e2ca-4481-8ce3-70406dfbcddc"></scheduled-study-segment>) }
      let(:response_body) { Nokogiri::XML(xml) }

      before(:each) do
        @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")

        Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Birth", :local_code => 18)
        Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "3 Month", :local_code => 23)
        Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "6 Month", :local_code => 24)
        Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "9 Month", :local_code => 26)
        Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "12 Month", :local_code => 27)
        Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "18 Month", :local_code => 30)
        Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "24 Month", :local_code => 31)
      end

      let(:psc) { PatientStudyCalendar.new(@user) }

      it "creates events for birth/child activities" do
        PatientStudyCalendar.stub!(:extract_scheduled_study_segment_identifier).and_return(scheduled_study_segment_identifier)
        psc.stub!(:template_snapshot).and_return(Nokogiri::XML(File.read(
              File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__))))

        VCR.use_cassette('psc/schedule_and_create_child_placeholder') do

          participant.person = person
          participant.save!

          participant.events.should be_empty
          Event.schedule_and_create_placeholder(psc, participant, "2012-08-09")
          participant.events.reload
          participant.events.should_not be_empty
          participant.events.size.should == 7
        end
      end

    end

  end

  context "matching against activity in PSC" do

    context "parsing psc labels" do
      describe "#parse_label" do
        it "returns the event portion of the label" do
          lbl = "event:low_intensity_data_collection instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
          Event.parse_label(lbl).should == "low_intensity_data_collection"
        end

        it "returns nil if label is blank" do
          lbl = ""
          Event.parse_label(lbl).should be_nil
        end

        it "returns nil if event portion is not included in label" do
          lbl = "instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
          Event.parse_label(lbl).should be_nil
        end
      end
    end

    describe "#matches_activity" do
      let(:event_type_code) { Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Low Intensity Data Collection", :local_code => 33) }
      let(:date) { "2012-02-29" }

      before(:each) do
        Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)

        @person = Factory(:person, :first_name => "Jane", :last_name => "Doe", :person_dob => '1980-02-14', :person_id => "janedoe_ppg2")
        @participant = Factory(:participant, :p_id => "janedoe_ppg2")
        @participant.person = @person
        @participant.save!

        @event = Factory(:event, :participant => @participant, :event_start_date => date, :event_end_date => nil, :event_type => event_type_code)
      end

      it "is true if event_type matches label and event_start_date matches ideal date" do
        lbl = "event:low_intensity_data_collection instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
        Struct.new("ScheduledActivity", :ideal_date, :labels)
        @event.matches_activity(Struct::ScheduledActivity.new(date, lbl)).should be_true
      end

      it "is false if event_type does not match label" do
        lbl = "event:not_the_event instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
        Struct.new("ScheduledActivity", :ideal_date, :labels)
        @event.matches_activity(Struct::ScheduledActivity.new(date, lbl)).should be_false
      end

      it "is false if event_start_date does not match ideal date" do
        lbl = "event:low_intensity_data_collection"
        Struct.new("ScheduledActivity", :ideal_date, :labels)
        @event.matches_activity(Struct::ScheduledActivity.new("2011-12-25", lbl)).should be_false
      end

    end

  end

end
