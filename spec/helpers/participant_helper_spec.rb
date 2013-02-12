# -*- coding: utf-8 -*-

require 'spec_helper'

describe ParticipantsHelper do
  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ParticipantsHelper)
  end

  context "text" do
    let(:event) { Factory(:event) }
    let(:lo_i_participant) { Factory(:low_intensity_ppg1_participant) }
    let(:hi_i_participant) { Factory(:high_intensity_ppg1_participant) }
    let(:lo_i_participant2) { Factory(:low_intensity_ppg2_participant) }
    let(:hi_i_participant2) { Factory(:high_intensity_ppg2_participant) }

    describe ".upcoming_events_for" do

      describe "non two-tier recruitment strategy" do

        before do
          helper.stub!(:recruitment_strategy => ProviderBased.new)
        end

        it "returns upcoming_events.to_s for a lo I participant" do
          expected = lo_i_participant.upcoming_events.first.to_s.gsub!("#{PatientStudyCalendar::LOW_INTENSITY}: ", '')
          helper.upcoming_events_for(lo_i_participant).should include(expected)

        end

        it "returns upcoming_events.to_s for a hi I participant" do
          dt = Date.parse("2012-12-25")
          hi_i_participant.events << Factory(:event, :participant => hi_i_participant,
                                              :event_start_date => dt, :event_end_date => dt,
                                              :event_type => NcsCode.pregnancy_screener)
          expected = hi_i_participant.upcoming_events.first.to_s.gsub!("#{PatientStudyCalendar::HIGH_INTENSITY}: ", '')
          helper.upcoming_events_for(hi_i_participant).should include(expected)
        end

      end

      describe "two-tier recruitment strategy" do

        before do
          helper.stub!(:recruitment_strategy => TwoTier.new)
        end

        it "returns Lo I: + upcoming_events.to_s for a lo I participant" do
          helper.upcoming_events_for(lo_i_participant).should include(lo_i_participant.upcoming_events.first.to_s)
        end

        it "returns Hi I: + upcoming_events.to_s for a hi I participant" do
          helper.upcoming_events_for(hi_i_participant).should include(hi_i_participant.upcoming_events.first.to_s)
        end

      end

    end

    describe ".displayable_next_scheduled_event" do

      let(:next_scheduled_lo_i_event) {
        lo_i_participant2.person = Factory(:person)
        Factory(:contact_link, :person => lo_i_participant2.person, :event => Factory( :event, :participant => lo_i_participant2),
                :contact => Factory(:contact, :contact_date_date => Date.new(2012, 02, 01)))
        lo_i_participant2.next_scheduled_event.event }
      let(:next_scheduled_hi_i_event) {
        hi_i_participant2.person = Factory(:person)
        Factory(:contact_link, :person => lo_i_participant2.person, :event => Factory( :event, :participant => hi_i_participant2),
        :contact => Factory(:contact, :contact_date_date => Date.new(2012, 02, 01)))
        hi_i_participant2.next_scheduled_event.event }

      describe "non two-tier recruitment strategy" do

        before do
          helper.stub!(:recruitment_strategy => ProviderBased.new)
        end

        it "returns next_scheduled_event.to_s for a lo I participant" do
          helper.displayable_next_scheduled_event(next_scheduled_lo_i_event).should == next_scheduled_lo_i_event.to_s
        end

        it "returns next_scheduled_event.to_s for a hi I participant" do
          helper.displayable_next_scheduled_event(next_scheduled_hi_i_event).should == next_scheduled_hi_i_event.to_s
        end

      end

      describe "two-tier recruitment strategy" do

        before do
          helper.stub!(:recruitment_strategy => TwoTier.new)
        end

        it "returns Lo I: + event.to_s for a lo I participant" do
          helper.displayable_next_scheduled_event(next_scheduled_lo_i_event).should == next_scheduled_lo_i_event.to_s
        end

        it "returns Hi I: + event.to_s for a hi I participant" do
          helper.displayable_next_scheduled_event(next_scheduled_hi_i_event).should == next_scheduled_hi_i_event.to_s
        end

      end

    end

  end

  describe "#strip_part" do
    describe "with a nil activity_name" do
      let(:name) { nil }
      it "returns an empty string" do
        helper.strip_part(name).should == ""
      end
    end

    describe "with a simple name" do
      let(:name) { "Thing" }
      it "returns the activity_name" do
        helper.strip_part(name).should == name
      end
    end

    describe "with an activity name that includes a 'Part One'" do
      let(:name) { "Thing Part One" }
      it "returns the activity_name minus the 'Part One'" do
        helper.strip_part(name).should == 'Thing'
      end
    end

    describe "with an activity name that includes 'Participant'" do
      let(:name) { "Participant Thing" }
      it "returns the activity_name" do
        helper.strip_part(name).should == name
      end
    end

    describe "with an activity name that includes both 'Participant' and a 'Part'" do
      let(:name) { "Participant Thing Part One" }
      it "returns the activity_name minus the 'Part One'" do
        helper.strip_part(name).should == "Participant Thing"
      end
    end

  end

  describe "#saq_confirmation_message" do
    let(:event_type) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', Event.birth_code) }
    let(:saq_confirmation_message) {
      "Would you like to record or add more information to the Self-Administered Questionnaire (SAQ)\nfor the #{event_type.to_s} Event?"
    }

    describe "with a closed event" do
      let(:event) { Factory(:event, :event_end_date => Date.parse("2525-12-25"), :event_type => event_type) }

      it "returns the confirmation message with a note that the event is closed" do
        msg = "This event is already closed.\n\n" + saq_confirmation_message
        helper.saq_confirmation_message(event).should == msg
      end

    end

    describe "with an open event" do
      let(:event) { Factory(:event, :event_end_date => nil, :event_type => event_type) }

      it "returns the confirmation message" do
        helper.saq_confirmation_message(event).should == saq_confirmation_message
      end
    end

  end

end
