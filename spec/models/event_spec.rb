# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130415192041
#
# Table name: events
#
#  created_at                         :datetime
#  event_breakoff_code                :integer          not null
#  event_comment                      :text
#  event_disposition                  :integer
#  event_disposition_category_code    :integer          not null
#  event_end_date                     :date
#  event_end_time                     :string(255)
#  event_id                           :string(36)       not null
#  event_incentive_cash               :decimal(12, 2)
#  event_incentive_noncash            :string(255)
#  event_incentive_type_code          :integer          not null
#  event_repeat_key                   :integer
#  event_start_date                   :date
#  event_start_time                   :string(255)
#  event_type_code                    :integer          not null
#  event_type_other                   :string(255)
#  id                                 :integer          not null, primary key
#  imported_invalid                   :boolean          default(FALSE), not null
#  lock_version                       :integer          default(0)
#  participant_id                     :integer
#  psc_ideal_date                     :date
#  psu_code                           :integer          not null
#  scheduled_study_segment_identifier :string(255)
#  transaction_type                   :string(255)
#  updated_at                         :datetime
#

require 'spec_helper'

require File.expand_path('../../shared/models/a_time_bounded_task', __FILE__)
require File.expand_path('../../shared/models/an_optimistically_locked_record', __FILE__)

describe Event do

  it "should create a new instance given valid attributes" do
    e = Factory(:event)
    e.should_not be_nil
  end

  it { should belong_to(:participant) }

  it { should have_many(:contact_links) }
  it { should have_many(:contacts).through(:contact_links) }
  it { should have_many(:instruments).through(:contact_links) }

  it_should_behave_like 'an optimistically locked record' do
    subject { Factory(:event) }

    def modify(winner, loser)
      winner.event_type_other = 'winner'
      loser.event_type_other = 'loser'
    end
  end

  describe "#set_psc_ideal_date" do
    let(:event) { Factory(:event, :event_start_date => start_date, :psc_ideal_date => ideal_date) }

    describe "for an event without an ideal date" do
      let(:start_date) { Date.parse('2525-12-25') }
      let(:ideal_date) { nil }
      it "sets the psc ideal date to the event start date before save" do
        event.psc_ideal_date.should == start_date
      end
    end

    describe "for an event without an ideal date" do
      let(:start_date) { Date.parse('2525-12-25') }
      let(:ideal_date) { Date.parse('2525-01-01') }
      it "does not override the existing value" do
        event.psc_ideal_date.should == ideal_date
      end
    end

  end

  describe 'to_s' do
    subject { Factory(:event) }
    it 'should use the event_type display_text' do
      subject.to_s.should == subject.event_type.display_text
    end

    describe 'if event_type is Other' do
      before(:each) do
        subject.event_type_code = -5
      end

      it 'should use the event_type display_text if event_type_other is nil' do
        subject.to_s.should == "Other"
      end

      it 'should use the event_type display_text if event_type_other is empty string' do
        subject.event_type_other = ""
        subject.to_s.should == "Other"
      end

      it 'should append the event_type_other value to event_type display_text if event_type_other is not blank' do
        subject.event_type_other = "Event ABC"
        subject.to_s.should == "Other - Event ABC"
      end
    end
  end

  it_should_behave_like 'a time-bounded task', 'event_end_date', '01/01/2000'

  describe '.chronological' do
    it 'orders events by their start date' do
      e1 = Factory(:event, :event_start_date => '01/01/2002')
      e2 = Factory(:event, :event_start_date => '01/01/2000')

      Event.chronological.should == [e2, e1]
    end

    it 'returns mutable records' do
      Factory(:event, :event_start_date => '01/01/2002')

      Event.chronological.any?(&:readonly?).should be_false
    end

    describe 'given a readonly query' do
      let(:rel) { Event.joins(:contact_links) }

      it 'does not make result sets mutable' do
        Factory(:event, :event_start_date => '01/01/2002')

        rel.chronological.all?(&:readonly?).should be_true
      end
    end

    describe 'within the same date' do
      let(:date) { '01/01/2000' }

      before do
        Event::TYPE_ORDER.shuffle.each do |etc|
          Event.create!(:event_type_code => etc, :event_start_date => date)
        end
      end

      it 'orders events by their type code' do
        Event.chronological.map(&:event_type_code).should == Event::TYPE_ORDER
      end
    end
  end

  describe ".event_start_time" do

    it "is set on create if nil" do
      e = Factory(:event, :event_start_time => nil, :event_start_date => Date.today)
      e.event_start_time.should_not be_nil
    end

    it "is NOT set on create if start_date is nil" do
      e = Factory(:event, :event_start_time => nil, :event_start_date => nil)
      e.event_start_time.should be_nil
    end


    it "takes a string" do
      e = Factory(:event)
      e.event_start_time = '00:00'
      e.save!
      e.event_start_time.should == '00:00'
    end

    it "takes Time" do
      now = Time.now
      e = Factory(:event)
      e.event_start_time = now
      e.save!
      e.event_start_time.should == now.strftime('%H:%M')
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

      e = Event.new
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

  describe '#completed?' do
    categories = {
      1 => 'Household Enumeration',
      2 => 'Pregnancy Screener',
      3 => 'General Study',
      4 => 'Mailed Back SAQ',
      5 => 'Telephone Interview',
      6 => 'Internet Survey'
    }

    table = {
      1 => { :complete => [40, 45], :incomplete => [10, 15, 46, 39] },
      2 => { :complete => (60..65), :incomplete => [10, 15, 66, 59] },
      3 => { :complete => (60..62), :incomplete => [10, 15, 63, 59] },
      4 => { :complete => (50..56), :incomplete => [10, 15, 49, 57] },
      5 => { :complete => (90..95), :incomplete => [10, 15, 89, 96] },
      6 => { :complete => (40..46), :incomplete => [10, 15, 39, 47] }
    }

    table.each do |num, spec|
      describe "for #{categories[num]} disposition codes" do
        let(:category) do
          NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', num)
        end

        spec[:complete].each do |code|
          it "returns true for code #{code}" do
            event = Event.new(:event_disposition_category => category, :event_disposition => code)

            event.should be_completed
          end
        end

        spec[:incomplete].each do |code|
          it "returns false for code #{code}" do
            event = Event.new(:event_disposition_category => category, :event_disposition => code)

            event.should_not be_completed
          end
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

    it 'has an item for every event type' do
      Event::TYPE_ORDER.size.should == NcsCode.where(:list_name => 'EVENT_TYPE_CL1').count
    end
  end

  describe ".enumeration_event?" do

    it "is true for provider base recruitment, screening, and enumeration events" do
      [1, 2, 22, 3, 4, 5, 6, 9, 29].each do |code|
        Factory(:event, :event_type_code => code).should be_enumeration_event
      end
    end

    it "is false for participant focused events" do
      [ 10, 33, 32, 7, 8, 11, 12,
        13, 14, 15, 16, 17, 18, 19, 20, 21, 23, 24,
        25, 26, 27, 28, 30, 31].each do |code|
        Factory(:event, :event_type_code => code).should_not be_enumeration_event
      end
    end

    it "is false for all negative event codes" do
      [-5, -4].each do |code|
        Factory(:event, :event_type_code => code).should_not be_enumeration_event
      end
    end
  end

  describe ".provider_event?"  do
    it "is true for provider base recruitment" do
      Factory(:event, :event_type_code => Event.provider_recruitment_code).should be_provider_event
    end
  end

  describe "#screener_event?" do
    it "is true for pregnancy_screener" do
      Factory(:event, :event_type_code => Event.pregnancy_screener_code).should be_screener_event
    end

    it "is true for pbs_eligibility_screener" do
      Factory(:event, :event_type_code => Event.pbs_eligibility_screener_code).should be_screener_event
    end

    it "is false for any other event" do
      Factory(:event, :event_type_code => Event.birth_code).should_not be_screener_event
    end
  end

  describe "type categories" do
    # Take care with these specs to make sure they can run regardless of MDES version.
    describe 'in relation to participants' do
      let(:all_real_event_type_codes) {
        NcsCode.where("list_name = 'EVENT_TYPE_CL1' AND local_code > 0").collect(&:local_code)
      }

      it 'knows which event types are not related a specific participant' do
        Event.non_participant_event_type_codes.should_not be_empty
      end

      it 'knows which participant event types should occur only once' do
        Event.participant_one_time_only_event_type_codes.should_not be_empty
      end

      it 'knows which participant event types can be repeated' do
        Event.participant_repeatable_event_type_codes.should_not be_empty
      end

      it 'only puts each event type code into one of these categories' do
        (Event.non_participant_event_type_codes & Event.participant_one_time_only_event_type_codes).should == []
        (Event.non_participant_event_type_codes & Event.participant_repeatable_event_type_codes).should == []
        (Event.participant_repeatable_event_type_codes & Event.participant_one_time_only_event_type_codes).should == []
      end

      it 'puts all real event types into one of these categories' do
        uncategorized_codes = all_real_event_type_codes -
          Event.participant_one_time_only_event_type_codes -
          Event.participant_repeatable_event_type_codes -
          Event.non_participant_event_type_codes

        uncategorized_codes.should == []
      end
    end
  end

  context "time format" do
    let(:record) { Factory(:event) }

    describe "#event_start_time" do
      it_behaves_like 'an MDES time'

      let(:time_attribute) { :event_start_time }
      let(:time_name) { "Event start time" }
    end

    describe "#event_end_time" do
      it_behaves_like 'an MDES time'

      let(:time_attribute) { :event_end_time }
      let(:time_name) { "Event end time" }
    end
  end

  context "auto-completing MDES data" do

    before(:each) do

      @person = Factory(:person)
      @participant = Factory(:participant, :high_intensity => true)
      @participant.person = @person
      @ppg_fu = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7)
      @preg_screen = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 29)
      @hh = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 1)

      @telephone = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3)
      @mail      = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 2)
      @in_person = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 1)
      @txtmsg    = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 5)
      @website   = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 6)

      @y = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)
      @n = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)

    end

    describe "the disposition category" do

      it "is first determined by the event type" do
        event = Event.create(
          :participant => @participant, :event_type => @preg_screen,
          :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes
        event.save!
        event.event_disposition_category.local_code.should == 2

        event = Event.create(
          :participant => @participant, :event_type => @hh,
          :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes
        event.save!
        event.event_disposition_category.local_code.should == 1
      end

      it "is next determined by the contact type" do
        # telephone
        contact = Factory(:contact, :contact_type => @telephone)
        event = Event.create(
          :participant => @participant, :event_type => @ppg_fu,
          :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 5

        # mail
        contact = Factory(:contact, :contact_type => @mail)
        event = Event.create(
          :participant => @participant, :event_type => @ppg_fu,
          :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 4

        # txt
        contact = Factory(:contact, :contact_type => @txtmsg)
        event = Event.create(
          :participant => @participant, :event_type => @ppg_fu,
          :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 5

        # website
        contact = Factory(:contact, :contact_type => @website)
        event = Event.create(
          :participant => @participant, :event_type => @ppg_fu,
          :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 6

        # in person
        contact = Factory(:contact, :contact_type => @in_person)
        event = Event.create(
          :participant => @participant, :event_type => @ppg_fu,
          :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 3

      end
    end
  end

  context "when scheduling an event with PSC " do
    let(:scheduled_study_segment_identifier) { "a5fd83f9-e2ca-4481-8ce3-70406dfbcddc" }
    let(:event_type_code) { NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33) }
    let(:person) {
      Factory(:person,
        :first_name => "Jane", :last_name => "Doe",
        :person_dob => '1980-02-14', :person_id => "placeholder_event_participant")
    }
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
      end

      let(:psc) { PatientStudyCalendar.new(@user) }
      let(:date) { "2012-02-06" }

      it "returns nil if there is no event to schedule" do
        part = Factory(:low_intensity_ppg5_participant)
        part.next_scheduled_event.should be_blank
        Event.schedule_and_create_placeholder(psc, part).should be_nil
      end

      it "returns nil if participant is not eligible" do
        part = Factory(:high_intensity_ppg1_participant)
        part.stub!(:eligible?).and_return(false)
        Event.schedule_and_create_placeholder(psc, part).should be_nil
      end

      it "creates events as for ppg followup activities" do

        PatientStudyCalendar.stub!(:extract_scheduled_study_segment_identifier).
          and_return("a5fd83f9-e2ca-4481-8ce3-70406dfbcddc")
        psc.stub!(:template_snapshot).and_return(Nokogiri::XML(File.read(
              File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__))))
        participant.stub!(:eligible?).and_return(true)

        VCR.use_cassette('psc/schedule_and_create_placeholder') do

          participant.person = person
          participant.save!
          Factory(:contact_link, :contact => Factory(:contact, :contact_date_date => Date.parse("2000-01-01")),
          :event => Factory(:event, :participant => participant), :person => participant.person)

          Event.schedule_and_create_placeholder(psc, participant, date)
          participant.events.reload
          participant.events.size.should == 3
          participant.events.select { |item| item.event_type_code != 1 }.each do |e|
            e.scheduled_study_segment_identifier.should == scheduled_study_segment_identifier
            e.event_start_date.to_s.should == date
          end
        end
      end

      it "cancels events for phase2 activities if configured to do so" do
        NcsNavigatorCore.with_specimens?.should be_false
        NcsNavigatorCore.expanded_phase_two?.should be_false

        PatientStudyCalendar.stub!(:extract_scheduled_study_segment_identifier).
          and_return("f6abc107-a24e-4169-a260-d407fe816910")
        psc.stub!(:template_snapshot).and_return(Nokogiri::XML(File.read(
              File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__))))

        date = Date.today
        part = Factory(:high_intensity_pregnancy_one_participant)
        part.person = Factory(:person)
        event = Factory(:event, :participant => part,
                                :event_start_date => date, :event_end_date => date,
                                :event_type => NcsCode.pregnancy_screener)
        part.events << event
        part.stub!(:eligible?).and_return(true)

        Factory(:contact_link, :event => event, :person => part.person,
                               :contact => Factory(:contact, :contact_date_date => date))

        part.next_scheduled_event.event.
          should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1

        phase2person = Factory(:person,
          :first_name => "Francesca", :last_name => "Zupicich", :person_dob => '1980-02-14',
          :person_id => "placeholder_phase2_participant")

        VCR.use_cassette('psc/schedule_and_create_phase2_placeholder') do

          part.person = phase2person
          part.save!

          Event.schedule_and_create_placeholder(psc, part, "2012-08-09")

          subject_schedule = psc.scheduled_activities(part)
          subject_schedule.size.should == 5

          subject_schedule.each do |s|
            s.study_segment.should == "HI-Intensity: Pregnancy Visit 1"
            s.ideal_date.should == "2012-08-09"
            s.should be_open
          end

        end

      end

    end
  end

  context "child events" do

    describe "#schedule_and_create_placeholder" do

      setup_schedule_and_create_child_placeholder

      it "creates events for birth/child activities" do
        PatientStudyCalendar.stub!(:extract_scheduled_study_segment_identifier).
          and_return(scheduled_study_segment_identifier)
        psc.stub!(:template_snapshot).and_return(Nokogiri::XML(File.read(
              File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__))))

        VCR.use_cassette('psc/schedule_and_create_child_placeholder') do
          participant.person = person
          participant.save!
          existing_event_date = '2010-01-01'

          Factory(:contact_link,
            :contact => Factory(:contact, :contact_date_date => existing_event_date),
            :event => Factory(:event, :participant => participant,
              :event_start_date => existing_event_date, :event_end_date => existing_event_date),
            :person => participant.person)

          participant.stub!(:eligible?).and_return(true)
          Event.schedule_and_create_placeholder(psc, participant, "2012-08-09")

          participant.pending_events.chronological.first.event_type.to_s.should == "Birth"
          participant.pending_events.chronological.last.event_type.to_s.should == "24 Month"
        end
      end

    end
  end

  context "matching against activity in PSC" do

    context "parsing psc labels" do
      describe "#parse_label" do
        it "returns the event portion of the label" do
          lbl = "event:low_intensity_data_collection instrument:2.0:ins_que_lipregnotpreg_int_li_p2_v2.0"
          Event.parse_label(lbl).should == "low_intensity_data_collection"
        end

        it "returns nil if label is blank" do
          lbl = ""
          Event.parse_label(lbl).should be_nil
        end

        it "returns nil if event portion is not included in label" do
          lbl = "instrument:2.0:ins_que_lipregnotpreg_int_li_p2_v2.0"
          Event.parse_label(lbl).should be_nil
        end
      end
    end

    describe "#matches_activity" do
      let(:event_type_code) { 33 }
      let(:date) { "2012-02-29" }

      before(:each) do
        @person = Factory(:person,
          :first_name => "Jane", :last_name => "Doe",
          :person_dob => '1980-02-14', :person_id => "janedoe_ppg2")
        @participant = Factory(:participant, :p_id => "janedoe_ppg2")
        @participant.person = @person
        @participant.save!

        @event = Factory(:event, :participant => @participant,
          :event_start_date => date, :event_end_date => nil, :event_type_code => event_type_code)
      end

      it "is true if event_type matches label and event_start_date matches ideal date" do
        lbl = "event:low_intensity_data_collection instrument:2.0:ins_que_lipregnotpreg_int_li_p2_v2.0"
        @event.matches_activity(ScheduledActivity.new(:ideal_date => date, :labels => lbl)).should be_true
      end

      it "is false if event_type does not match label" do
        lbl = "event:not_the_event instrument:2.0:ins_que_lipregnotpreg_int_li_p2_v2.0"
        @event.matches_activity(ScheduledActivity.new(:ideal_date => date, :labels => lbl)).should be_false
      end

      it "is false if event_start_date does not match ideal date" do
        lbl = "event:low_intensity_data_collection"
        @event.matches_activity(ScheduledActivity.new(:ideal_date => "2011-12-25", :labels => lbl)).should be_false
      end

    end
  end

  describe ".determine_repeat_key" do

    let(:participant) { Factory(:participant) }

    it "returns n-1 for the nth event of this type for the participant" do
      [7, 11, 13, 18, 23, 32, 33].each do |event_type_code|
        3.times do |n|
          event = Factory(:event, :event_type_code => event_type_code, :participant => participant)
          event.determine_repeat_key.should == n
        end
      end
    end

    it "returns 0 if the participant is nil" do
      Factory(:event, :participant => nil).determine_repeat_key.should == 0
    end

  end

  describe '#scheduled_activities' do
    let(:event) { Factory(:event) }

    describe "if the given PscParticipant does not match this event's participant" do
      let(:psc_participant) { stub(:participant => Participant.new) }

      it 'raises an error' do
        lambda { event.scheduled_activities(psc_participant) }.should raise_error
      end
    end

    # See PscParticipant#scheduled_activities.
    let(:schedule) do
      {
        'foo' => sa(:labels => ['event:pregnancy_visit_1'], :ideal_date => '2012-01-01', :activity_id => 'foo'),
        'bar' => sa(:labels => ['event:pregnancy_visit_1'], :ideal_date => '2012-01-01', :activity_id => 'bar'),
        'baz' => sa(:labels => ['event:pregnancy_visit_2'], :ideal_date => '2012-02-02', :activity_id => 'baz')
      }
    end

    let(:psc_participant) { stub(:participant => event.participant) }

    it 'returns activities whose label and ideal date match' do
      # Pregnancy Visit 1.
      event.event_type = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 13)
      event.psc_ideal_date = '2012-01-01'
      psc_participant.stub!(:scheduled_activities).and_return(schedule)

      event.scheduled_activities(psc_participant).should == [
        sa(:labels => ['event:pregnancy_visit_1'], :ideal_date => '2012-01-01', :activity_id => 'foo'),
        sa(:labels => ['event:pregnancy_visit_1'], :ideal_date => '2012-01-01', :activity_id => 'bar')
      ]
    end
  end

  describe '#disposition_code' do
    let(:version) { NcsNavigator::Core::Mdes::Version.new('3.1') }
    let(:spec) { version.specification }
    let(:code) { spec.disposition_codes.first }

    describe 'example' do
      it 'uses a non-nil code' do
        code.should_not be_nil
      end
    end

    around do |example|
      begin
        old_version = NcsNavigatorCore.mdes_version
        NcsNavigatorCore.mdes_version = version
        example.call
      ensure
        NcsNavigatorCore.mdes_version = old_version
      end
    end

    it "returns the disposition code for the event's category and interim codes" do
      event = Event.new(:event_disposition => code.interim_code.to_i, :event_disposition_category_code => code.category_code.to_i)

      event.disposition_code.should == code
    end
  end

  describe '#desired_sa_state' do
    let(:event) { Event.new }
    let(:desired_sa_state) { event.desired_sa_state }

    let(:successful_dc) do
      NcsNavigatorCore.mdes.disposition_codes.detect(&:success?)
    end

    let(:unsuccessful_dc) do
      NcsNavigatorCore.mdes.disposition_codes.detect { |dc| !dc.success? }
    end

    SA = Psc::ScheduledActivity

    describe 'if the event is closed' do
      before do
        event.stub!(:closed? => true)
      end

      describe 'and the disposition is successful' do
        before do
          event.disposition_code = successful_dc
        end

        it 'returns OCCURRED' do
          desired_sa_state.should == SA::OCCURRED
        end
      end

      describe 'and the disposition is unsuccessful' do
        before do
          event.disposition_code = unsuccessful_dc
        end

        it 'returns CANCELED' do
          desired_sa_state.should == SA::CANCELED
        end
      end
    end

    describe 'if the event is open' do
      it 'returns SCHEDULED' do
        desired_sa_state.should == SA::SCHEDULED
      end
    end
  end

  describe '#sa_end_date' do
    let(:event) { Event.new }

    it 'is #event_end_date in YYYY-MM-DD format' do
      event.event_end_date = '2012-01-01'

      event.sa_end_date.should == '2012-01-01'
    end

    it 'is nil if #event_end_date is nil' do
      event.event_end_date = nil

      event.sa_end_date.should be_nil
    end
  end

  describe '#sa_state_change_reason' do
    let(:event) { Event.new }

    it 'is "Synchronized from Cases"' do
      event.sa_state_change_reason.should == 'Synchronized from Cases'
    end
  end

  describe "CONTINUABLE" do

    it "includes PBS Participant Eligibility Screening as a continuable event" do
      Event::CONTINUABLE.should include("PBS Participant Eligibility Screening")
    end
  end

  describe ".open_contacts?" do

    let(:contact) { Factory(:contact, :contact_end_time => nil) }
    let(:event) { Factory(:event) }
    let(:contact_link) { Factory(:contact_link, :contact => contact, :event => event) }

    it "returns true if any contact associated with the event is open" do
      contact_link.event.open_contacts?.should be_true
    end

    it "returns false if there are no opend contacts associated with the event" do
      contact_link.contact.update_attribute(:contact_end_time, "12:00")
      contact_link.event.open_contacts?.should be_false
    end
  end

  describe '#label' do
    let(:event) { Event.new(:event_type => et) }
    let(:et) { NcsCode.new }

    it 'turns Foo Bar into foo_bar' do
      et.display_text = 'Foo Bar'

      event.label.should == 'foo_bar'
    end

    it 'squeezes spaces' do
      et.display_text = 'Foo    Bar'

      event.label.should == 'foo_bar'
    end
  end

  describe ".update_associated_informed_consent_event" do

    let(:contact) { Factory(:contact) }
    let(:participant) { Factory(:participant) }
    let!(:pv1_event) { Factory(:event, :event_type_code => Event.pregnancy_visit_1_code, :participant => participant) }
    let!(:ic_event) { Factory(:event, :event_type_code => Event.informed_consent_code, :participant => participant) }
    let!(:pv1_contact_link) { Factory(:contact_link, :contact => contact, :event => pv1_event) }
    let!(:ic_contact_link) { Factory(:contact_link, :contact => contact, :event => ic_event) }

    before do
      dt = Date.parse("2525-01-01")
      @expected_values = [
        [:event_disposition_category_code, 3],
        [:event_disposition, 60],
        [:event_start_date, dt],
        [:event_start_time, "11:11"],
        [:event_end_date, dt],
        [:event_end_time, "12:12"]
      ]
      @expected_values.each do |a, v|
        pv1_event.send("#{a}=", v)
        ic_event.send("#{a}=", nil)
      end
      pv1_event.save!
      ic_event.save!
    end

    it "updates the associated Informed Consent event" do
      pv1_event.update_associated_informed_consent_event
      updated_ic_event = Event.find(ic_event.id)
      @expected_values.each do |a, v|
        updated_ic_event.send(a).should == v
      end
    end

    it "does not override existing valid attributes" do
      other_date = Date.parse("2020-12-25")
      midnight = "00:00"
      ic_event.event_start_date = other_date
      ic_event.event_start_time = midnight
      ic_event.event_end_date = other_date
      ic_event.event_end_time = midnight
      ic_event.save!

      pv1_event.update_associated_informed_consent_event
      updated_ic_event = Event.find(ic_event.id)

      updated_ic_event.event_start_date.should == other_date
      updated_ic_event.event_start_time.should == midnight
      updated_ic_event.event_end_date.should == other_date
      updated_ic_event.event_end_time.should == midnight
    end
  end

  describe "#valid?" do

    let(:valid)   { Factory.build(:event, :event_disposition_category_code => 3, :event_disposition => 60) }
    let(:invalid) { Factory.build(:event, :event_disposition_category_code => 3, :event_disposition => 65) }
    let(:missing) { Factory.build(:event, :event_disposition_category_code => -4, :event_disposition => 65) }

    it "returns true if the event_disposition is within the event_disposition_category_code" do
      valid.should be_valid
    end

    it "sreturns true if event_disposition_category_code is 'missing in error'" do
      missing.should be_valid
    end

    it "returns false if the event_disposition does not match the event_disposition_category_code" do
      invalid.should_not be_valid
    end

    it "creates a descriptive error" do
      expect do
        invalid.save!
      end.to raise_error(ActiveRecord::RecordInvalid,
        "Validation failed: Event disposition does not exist in the disposition category.")
    end

    it "skips the validation for invalid event_disposition combination if imported_invalid is set to 'true'" do
      invalid.imported_invalid = true
      invalid.should be_valid
    end

  end

  describe '#match_consents_by_date' do
    let(:event) {
      Factory(:event,
        :event_start_date => Date.new(2010, 3, 1),
        :event_end_date => Date.new(2010, 4, 1),
        :participant => event_participant
      )
    }

    let(:event_participant) { Factory(:participant, :participant_consents => [event_participant_consent]) }
    let(:event_participant_consent) { Factory(:participant_consent, :consent_date => Date.new(2010, 3, 15)) }

    let(:consent_feb) { Factory(:participant_consent, :consent_date => Date.new(2010, 2, 15)) }
    let(:consent_mar) { Factory(:participant_consent, :consent_date => Date.new(2010, 3, 15)) }
    let(:consent_apr) { Factory(:participant_consent, :consent_date => Date.new(2010, 4, 15)) }

    let(:consents) { [consent_feb, consent_mar, consent_apr] }

    it 'considers the consents for the associated participant if none given' do
      event.match_consents_by_date.first.should be event_participant_consent
    end

    it 'considers only the given consents if any given' do
      event.match_consents_by_date(consents).first.should be consent_mar
    end

    let(:matches) { event.match_consents_by_date(consents) }

    it 'finds just the consents within the date range for the event' do
      matches.should == [consent_mar]
    end

    it 'includes consents on the start date' do
      event.event_start_date = consent_feb.consent_date
      matches.should == [consent_feb, consent_mar]
    end

    it 'includes consents on the end date' do
      event.event_end_date = consent_apr.consent_date
      matches.should == [consent_mar, consent_apr]
    end

    it 'treats a nil start date as unbounded into the past' do
      event.event_start_date = nil
      matches.should == [consent_feb, consent_mar]
    end

    it 'treats a nil end date as unbounded into the future' do
      event.event_end_date = nil
      matches.should == [consent_mar, consent_apr]
    end

    it 'does not include consents without a consent date' do
      event.event_start_date = Date.new(2010, 2, 1)
      consent_mar.consent_date = nil
      matches.should == [consent_feb]
    end
  end

  context "Setting suggest values for event" do
    before do
      @person       = Factory(:person)
      @participant  = Factory(:participant)
      @contact      = Factory(:contact)
      @event        = Factory(:event)
      @instrument   = Factory(:instrument)
      @contact_link = Factory(:contact_link,
                              :person => @person,
                              :contact => @contact,
                              :event => @event,
                              :instrument => @instrument)
      @person.participant = @participant
      @event.participant  = @participant
      @event.event_disposition_category_code = -4
    end

    describe "#set_suggested_event_disposition" do
      it "equals associated contact link's contact contact disposition" do
        @contact.contact_disposition = 3
        @event.set_suggested_event_disposition(@contact_link).should == 3
      end
    end

    describe "#set_suggested_event_disposition_category" do
      it "returns event disposition category code with local
          code of 5 when particpant associated with event is low
          intensity" do
        # Givens
        @participant.stub(:low_intensity => true)
        @event.event_type = NcsCode.for_attribute_name_and_local_code(:event_type_code, 33)
        @event.set_suggested_event_disposition_category(@contact_link)
        @event.event_disposition_category.local_code.should == 5
      end
      it "leaves event_disposition as is when event disposition category code is positive" do
        @event.event_disposition_category_code = 1
        ed_before = @event.event_disposition
        @event.set_suggested_event_disposition_category(@contact_link)
        @event.event_disposition = ed_before
      end

      it "returns event disposition category code with local
          code of 8 when event is PBS eligibility screener" do
        @event.event_type = NcsCode.for_attribute_name_and_local_code(:event_type_code, 34)
        @event.set_suggested_event_disposition_category(@contact_link)
        @event.event_disposition_category.local_code.should == 8
      end

      it "returns event disposition category code with local
          code of 6 when contact is from a website (with high intensity participant" do
        @participant.stub(:low_intensity? => false)
        @contact.contact_type = NcsCode.for_attribute_name_and_local_code(:contact_type_code, 6)
        @event.event_type = NcsCode.for_attribute_name_and_local_code(:event_type_code, 18)
        @event.set_suggested_event_disposition_category(@contact_link)
        @event.event_disposition_category.local_code.should == 6
      end
    end

    describe "#set_suggested_event_repeat_key" do
      it "returns count how many times associated participant has repeated this type of event" do
        past_event_one = Factory(:event, :participant => @participant, :event_type_code => 1)
        past_event_two = Factory(:event, :participant => @participant, :event_type_code => 1)
        @event.set_suggested_event_repeat_key.should == 1
      end
    end

    describe "#set_suggested_event_breakoff" do
      include NcsNavigator::Core::Surveyor::SurveyTaker

      let(:survey) do
        Surveyor::Parser.new.parse <<-END
          survey "Test survey" do
            section "Section 1" do
              q_foo "A question"
              a :string
            end

            section "Section 2" do
              q_bar "Another question"
              a :string
            end
          end
        END
      end

      let(:rs) { Factory(:response_set, :survey => survey, :user_id => @person.id) }

      before do
        @event.event_breakoff_code = -4
        @event.save!
        @instrument.response_sets << rs
      end

      it "returns no if associated instrument response sets does not have any sections with zero responses" do
        respond(rs) do |r|
          r.answer 'foo', :value => 'abc'
          r.answer 'bar', :value => 'def'
        end

        rs.save!

        @event.set_suggested_event_breakoff(@contact_link)
        @event.event_breakoff.local_code.should == NcsCode::NO
      end

      it "returns yes if associated instrument response sets have any sections with zero responses" do
        respond(rs) do |r|
          r.answer 'foo', :value => 'abc'
        end

        rs.save!

        @event.set_suggested_event_breakoff(@contact_link)
        @event.event_breakoff.local_code.should == NcsCode::YES
      end

      it "does nothing if the event has been closed" do
        previous = @event.event_breakoff_code
        @event.event_end_date = Date.parse('2525-12-25')
        @event.set_suggested_event_breakoff(@contact_link)
        @event.event_breakoff_code.should == previous
      end

      it "does nothing if the event_breakoff_code has already been set" do
        respond(rs) do |r|
          r.answer 'foo', :value => 'abc'
          r.answer 'bar', :value => 'def'
        end

        rs.save!

        @event.event_breakoff_code = NcsCode::YES
        @event.set_suggested_event_breakoff(@contact_link)
        # see above that the rs should make this a NO
        @event.event_breakoff_code.should == NcsCode::YES
      end
    end

    describe "#stand_alone_event?" do
      let(:event) { Factory(:event) }
      let(:contact) { Factory(:contact) }
      let!(:contact_link) { Factory(:contact_link, :event => event, :contact => contact) }

      describe "when associated with another event in same contact" do

        it "is false" do
          other_event = Factory(:event)
          other_contact_link = Factory(:contact_link, :event => other_event, :contact => contact)
          event.stand_alone_event?(contact).should be_false
        end

      end

      describe "when NOT associated with another event in same contact" do

        it "is true" do
          event.stand_alone_event?(contact).should be_true
        end

      end

    end
  end

  describe "#window" do
    let(:birth_date) { Date.parse('2013-02-10') }

    describe "#window(:start,date,intensity)" do
      it "returns the date the child turns the age of the start month" do
        [
          [Event.birth_code,             '2013-02-10'],
          [Event.three_month_visit_code, '2013-04-10'],
          [Event.six_month_visit_code,   '2013-07-10'],
          [Event.nine_month_visit_code,  '2013-10-10'],
          [Event.pv1_code,                        nil]
        ].each do |event_type_code, expected|
          event = Factory(:event, :event_type_code => event_type_code)
          event.window(:start,birth_date,:high).should == (expected.nil? ? nil : Date.parse(expected))
        end

        [
          [Event.birth_code,             '2013-02-10'],
          [Event.three_month_visit_code, '2013-04-10'],
          [Event.six_month_visit_code,            nil],
          [Event.nine_month_visit_code,  '2013-09-10'],
          [Event.pv1_code,                        nil]
        ].each do |event_type_code, expected|
          event = Factory(:event, :event_type_code => event_type_code)
          event.window(:start,birth_date,:low).should == (expected.nil? ? nil : Date.parse(expected))
        end

      end
    end

    describe "#window(:end,date,intensity)" do
      it "returns the last day of the end month of the PO designed visit windows
          i.e. the day before the child turns the next month of age." do
        [
          [Event.birth_code,             '2013-02-20'],
          [Event.three_month_visit_code, '2013-07-09'],
          [Event.six_month_visit_code,   '2013-10-09'],
          [Event.nine_month_visit_code,  '2014-01-09'],
          [Event.pv1_code,                        nil]
        ].each do |event_type_code, expected|
          event = Factory(:event, :event_type_code => event_type_code)
          event.window(:end,birth_date,:high).should == (expected.nil? ? nil : Date.parse(expected))
        end
        [
          [Event.birth_code,             '2013-04-9'],
          [Event.three_month_visit_code, '2013-09-09'],
          [Event.six_month_visit_code,            nil],
          [Event.nine_month_visit_code,  '2014-04-09'],
          [Event.pv1_code,                        nil]
        ].each do |event_type_code, expected|
          event = Factory(:event, :event_type_code => event_type_code)
          event.window(:end,birth_date,:low).should == (expected.nil? ? nil : Date.parse(expected))
        end
      end
    end

    context "with a participant" do
      let(:mother) do
        mother  = Factory(:participant_person_link,
                          :person => Factory(:person, :person_dob => '1988-01-01'),
                          :participant => Factory(:participant, :high_intensity => true))
      end

      let(:child1) do
        Factory(:participant_person_link,
                :person => Factory(:person, :person_dob => '2013-02-10'),
                :participant => Factory(:participant, :high_intensity => true))
      end

      let(:child2) do
        Factory(:participant_person_link,
                :person => Factory(:person, :person_dob => '2013-02-10'),
                :participant => Factory(:participant, :high_intensity => true))
      end

      it "returns a date when the event is associated with the child" do
        link = Factory(:participant_person_link,
                       :participant => child1.participant,
                       :person => mother.person,
                       :relationship_code => 2) # mother
        event = Factory(:event, :event_type_code => Event.birth_code, :participant => child1.participant)

        event.window(:start).should == Date.parse('2013-02-10')
        event.window(:end).should == Date.parse('2013-02-20')
      end

      it "returns a date when the event is associated with the mother and there is one child" do
        Factory(:participant_person_link,
                :participant => mother.participant,
                :person => child1.person,
                :relationship_code => 8) # child
        event = Factory(:event, :event_type_code => Event.birth_code, :participant => mother.participant)

        event.window(:start).should == Date.parse('2013-02-10')
        event.window(:end).should == Date.parse('2013-02-20')
      end

      it "returns a date when the event is associated with the mother and there are multiple children with the same birthday" do
        Factory(:participant_person_link,
                :participant => mother.participant,
                :person => child1.person,
                :relationship_code => 8) # child
        Factory(:participant_person_link,
                :participant => mother.participant,
                :person => child2.person,
                :relationship_code => 8) # child
        event = Factory(:event, :event_type_code => Event.birth_code, :participant => mother.participant)

        event.window(:start).should == Date.parse('2013-02-10')
        event.window(:end).should == Date.parse('2013-02-20')
      end

      # this is a bug, when the child participant is associated with the event it can be removed
      it "returns the correct date when the event is associated with the mother and there are multiple children with different birthdays"

      it "returns nil when there is no child" do
        event = Factory(:event, :event_type_code => Event.birth_code, :participant => mother.participant)

        event.window(:start).should == nil
        event.window(:end).should == nil
      end

      it "returns nil when there is a child but the event has no window" do
        Factory(:participant_person_link,
                :participant => mother.participant,
                :person => child1.person,
                :relationship_code => 8) # child
        event = Factory(:event,
                        :event_type_code => Event.twelve_month_mother_interview_saq_visit_code,
                        :participant => mother.participant)

        event.window(:start).should == nil
        event.window(:end).should == nil
      end
      it "returns nil when there is no child" do
        event = Factory(:event,
                        :event_type_code => Event.pv1_code,
                        :participant => mother.participant)

        event.window(:start).should == nil
        event.window(:end).should == nil
      end
    end
  end
end
