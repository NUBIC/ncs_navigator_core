# -*- coding: utf-8 -*-

require 'spec_helper'

require File.expand_path('../../shared/custom_recruitment_strategy', __FILE__)

describe Participant do
  context "a new participant" do

    it "is scheduled for the LO-Intensity Pregnancy Screener if not registered with the Patient Study Calendar (PSC)" do

      participant = Factory(:participant)
      participant.person = Factory(:person)
      date = Date.parse("2000-01-01")
      Factory(:contact_link, :contact => Factory(:contact, :contact_date_date => date),
          :event => Factory(:event, :participant => participant), :person => participant.person)
      participant.should be_pending
      participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
      participant.next_scheduled_event.event.should == participant.next_study_segment
    end

  end

  context "for the PBS protocol" do
    include_context 'custom recruitment strategy'

    let(:recruitment_strategy) { ProviderBasedSubsample.new }

    context "who has not completed the PBS Eligibility Screener event" do

      let(:participant) { Factory(:participant) }
      let(:person) { Factory(:person) }
      let(:date) { Date.parse("2000-01-01") }

      before(:each) do
        participant.person = person
        Factory(:contact_link, :contact => Factory(:contact, :contact_date_date => date),
          :event => Factory(:event, :participant => participant), :person => person)
      end

      it "is scheduled for the PBS Eligibility Screener event on that day" do
        participant.next_study_segment.should == PatientStudyCalendar::PBS_ELIGIBILITY_SCREENER
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == date
      end

    end
  end

  context "in the low intensity arm" do

    context "a registered participant" do

      let(:participant) { Factory(:participant) }
      let(:person) { Factory(:person) }
      let(:date) { Date.parse("2000-01-01") }

      before(:each) do
        participant.person = person
        Factory(:contact_link, :contact => Factory(:contact, :contact_date_date => date),
          :event => Factory(:event, :participant => participant), :person => person)
        participant.register!
      end

      it "is scheduled for the LO-Intensity Pregnancy Screener event on that day" do
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == date
      end

    end

    context "assigned to pregnancy probability group" do

      context "PPG Group 1: Pregnant and Eligible" do

        let(:participant) { Factory(:low_intensity_ppg1_participant) }
        let(:person) { Factory(:person) }
        let(:date) { Date.parse("2000-01-01") }

        before(:each) do
          participant.person = person
          event = Factory(:event, :participant => participant,
                              :event_start_date => date, :event_end_date => date,
                              :event_type => NcsCode.pregnancy_screener)
          participant.events << event
          contact = Factory(:contact, :contact_date_date => date)
          contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => person)
        end

        it "should schedule the LO-Intensity Quex" do
          participant.ppg_status.local_code.should == 1
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == date
        end

        describe "participant is consented and known to be pregnant" do
          it "schedules the LO-Intensity Birth Visit Interview the day after the due_date" do
            participant.should be_in_pregnancy_probability_group
            participant.should be_known_to_be_pregnant
            participant.impregnate_low!
            lo_i_quex = Factory(:event, :participant => participant, :event_start_date => date, :event_end_date => Date.today,
                                :event_type => NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33))
            participant.events << lo_i_quex

            participant.stub!(:due_date).and_return { 150.days.since(date).to_date }

            participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_BIRTH_VISIT_INTERVIEW
            participant.next_scheduled_event.event.should == participant.next_study_segment
            participant.next_scheduled_event.date.should == 151.days.since(date).to_date
          end

          it "is eligible to be moved in the high intensity arm if in tsu" do
            du = Factory(:dwelling_unit, :ssu_id => 'ssu', :tsu_id => 'tsu')
            hh = Factory(:household_unit)
            dh_link = Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hh)
            hh_pers_link = Factory(:household_person_link, :household_unit => hh, :person => participant.person)

            Factory(:event, :event_type => NcsCode.low_intensity_data_collection,
                    :participant => participant, :event_end_date => date)

            participant.should be_in_tsu
            participant.should be_eligible_for_high_intensity_invitation
          end

        end

        describe "participant has given birth" do
          it "schedules the LO-Intensity Postnatal segment 6.months after the birth event" do
            participant.should be_in_pregnancy_probability_group
            participant.should be_known_to_be_pregnant
            participant.impregnate_low!
            participant.birth_event_low!

            event_type = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 18)
            event = Factory(:event, :participant => participant, :event_end_date => date, :event_type => event_type)
            participant.events << event
            participant.save!
            Factory(:contact_link, :contact => Factory(:contact, :contact_date_date => date), :event => event, :person => participant.person)
            participant.should be_postnatal
            participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_POSTNATAL
            participant.next_scheduled_event.event.should == participant.next_study_segment
            participant.next_scheduled_event.date.should == 6.months.since(date).to_date
          end
        end

        it "is NOT eligible to be moved in the high intensity arm if NOT in tsu" do
          du = Factory(:dwelling_unit, :ssu_id => 'ssu', :tsu_id => nil)
          hh = Factory(:household_unit)
          dh_link = Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hh)
          hh_pers_link = Factory(:household_person_link, :household_unit => hh, :person => participant.person)

          participant.should_not be_in_tsu
          participant.should_not be_eligible_for_high_intensity_invitation
        end

      end

      context "PPG Group 2: High Probability - Trying to Conceive" do

        let(:participant) { Factory(:low_intensity_ppg2_participant) }
        let(:person) { Factory(:person) }
        let(:date) { Date.parse("2000-01-01") }

        before(:each) do
          # date = Date.parse("2000-01-01")
          participant.person = person
          event = Factory(:event, :participant => participant,
                              :event_start_date => date, :event_end_date => date,
                              :event_type => NcsCode.pregnancy_screener)
          participant.events << event
          contact = Factory(:contact, :contact_date_date => date)
          Factory(:contact_link, :contact => contact, :event => event, :person => person)
        end

        it "schedules the LO-Intensity PPG 1 and 2 event on that day" do

          participant.ppg_status.local_code.should == 2
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == date
        end

        it "schedules the LO-Intensity PPG Follow Up event 6 months out after the Low Intensity questionnaire" do
          participant.ppg_status.local_code.should == 2
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2

          event_type = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33)
          end_date = Date.parse("2000-02-01")
          event = Factory(:event, :participant => participant, :event_end_date => end_date,
                          :event_type => NcsCode.low_intensity_data_collection)
          contact = Factory(:contact, :contact_date_date => end_date)
          contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => participant.person)

          participant.events.reload
          participant.pending_events.should be_empty
          participant.events.should include(event)
          participant.events.last.event_type_code.should == NcsCode.low_intensity_data_collection.local_code

          participant.follow_low_intensity!
          participant.should be_following_low_intensity
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == 6.months.since(end_date).to_date
        end

        it "schedules the LO-Intensity PPG 1 and 2 event if follow_low_intensity but lo I quex event is pending" do
          event_type = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33)
          event = Factory(:event, :participant => participant, :event_end_date => nil, :event_type => event_type)
          participant.events.reload
          participant.pending_events.should == [event]

          participant.ppg_status.local_code.should == 2
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2

          participant.follow_low_intensity!
          participant.should be_following_low_intensity

          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == date
        end

        it "is eligible to be moved in the high intensity arm if in tsu" do
          du = Factory(:dwelling_unit, :ssu_id => 'ssu', :tsu_id => 'tsu')
          hh = Factory(:household_unit)
          dh_link = Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hh)
          hh_pers_link = Factory(:household_person_link, :household_unit => hh, :person => participant.person)

          Factory(:event, :event_type => NcsCode.low_intensity_data_collection,
                  :participant => participant, :event_end_date => Date.today)

          participant.person.should be_in_tsu
          participant.should be_in_tsu
          participant.should be_eligible_for_high_intensity_invitation
        end

        it "is NOT eligible to be moved in the high intensity arm if NOT in tsu" do
          participant.should_not be_in_tsu
          participant.should_not be_eligible_for_high_intensity_invitation
        end

        it "is NOT eligible to be moved in the high intensity until participant has taken Lo I Quex" do
          du = Factory(:dwelling_unit, :ssu_id => 'ssu', :tsu_id => 'tsu')
          hh = Factory(:household_unit)
          dh_link = Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hh)
          hh_pers_link = Factory(:household_person_link, :household_unit => hh, :person => participant.person)

          participant.should be_in_tsu
          participant.should_not be_eligible_for_high_intensity_invitation

          participant.completed_event?(NcsCode.low_intensity_data_collection).should be_false
        end

      end

      context "PPG Group 3: High Probability - Recent Pregnancy Loss" do
        let(:participant) { Factory(:low_intensity_ppg3_participant) }
        let(:person) { Factory(:person) }
        let(:date) { Date.parse("2000-01-01") }
        let(:event) { Factory(:event, :participant => participant,
                              :event_start_date => date, :event_end_date => date,
                              :event_type => NcsCode.pregnancy_screener) }

        before(:each) do
          participant.person = person
          participant.events << event
        end

        it "schedules the LO-Intensity PPG Follow Up event 6 months out" do
          contact = Factory(:contact, :contact_date_date => date)
          contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => person)

          participant.ppg_status.local_code.should == 3
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == 6.months.since(date).to_date
        end

        it "is NOT eligible to be moved in the high intensity arm" do
          du = Factory(:dwelling_unit, :ssu_id => 'ssu', :tsu_id => 'tsu')
          hh = Factory(:household_unit)
          dh_link = Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hh)
          hh_pers_link = Factory(:household_person_link, :household_unit => hh, :person => participant.person)

          participant.should be_in_tsu
          participant.should_not be_eligible_for_high_intensity_invitation
        end

      end

      context "PPG Group 4: Other Probability - Not Pregnant and not Trying" do
        let(:participant) { Factory(:low_intensity_ppg4_participant) }
        let(:person) { Factory(:person) }
        let(:date) { Date.parse("2000-01-01") }
        let(:event) { Factory(:event, :participant => participant,
                              :event_start_date => date, :event_end_date => date,
                              :event_type => NcsCode.pregnancy_screener) }

        before(:each) do
          participant.person = person
          participant.events << event
        end

        it "schedules the LO-Intensity PPG Follow Up event 6 months out" do
          contact = Factory(:contact, :contact_date_date => date)
          contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => person)

          participant.ppg_status.local_code.should == 4
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == 6.months.since(date).to_date
        end
      end
    end
  end

  context "in the high intensity arm" do

    context "a registered ppg1 participant" do

      let(:participant) { Factory(:high_intensity_ppg1_participant) }
      let(:person) { Factory(:person) }
      let(:date) { Date.parse("2001-01-10") }
      let(:event) { Factory(:event, :participant => participant,
                                      :event_start_date => date, :event_end_date => date,
                                      :event_type => NcsCode.pregnancy_screener) }

      before(:each) do
        participant.person = person
        participant.events << event

        contact = Factory(:contact, :contact_date_date => date)
        contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => person)
      end

      it "must first go through the LO-Intensity HI-LO Conversion event immediately" do
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == date
      end

      it "must consent to the High Intensity protocol and then the first pregnancy visit is scheduled" do


        participant.pregnant_informed_consent!
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == date
      end

      it "schedules the second pregnancy visit after the first pregnancy visit" do
        participant.pregnant_informed_consent!
        participant.pregnancy_one_visit!
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_2
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == 60.days.since(date).to_date
      end

      it "schedules the birth visit after the second pregnancy visit" do
        participant.pregnant_informed_consent!
        participant.pregnancy_one_visit!
        participant.pregnancy_two_visit!

        participant.stub!(:due_date).and_return { 270.days.since(date).to_date }

        participant.next_study_segment.should == PatientStudyCalendar::CHILD_CHILD
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == 271.days.since(date).to_date
      end

      describe "having a due date before the next scheduled event date" do

        let(:status) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1) }
        let(:date) { Date.parse("2000-02-09") }

        before(:each) do
          @due_date = 24.days.since(date).to_date
          Factory(:ppg_detail, :participant => participant, :ppg_first => status, :orig_due_date => @due_date)
        end

        describe "without a known contact" do
          it "schedules the birth event before Pregnancy Visit 2" do
            participant.pregnant_informed_consent!
            participant.pregnancy_one_visit!

            participant.next_study_segment.should == PatientStudyCalendar::CHILD_CHILD
            participant.next_scheduled_event.event.should == participant.next_study_segment
            participant.next_scheduled_event.date.should == 25.days.since(date).to_date
          end
        end

        describe "with a known contact" do
          before(:each)  do
            @due_date = Date.parse("2000-09-09")
            Factory(:ppg_detail, :participant => participant, :ppg_first => status, :orig_due_date => @due_date)
          end

          describe "where the contact is less than 60 days before the due date" do
            it "schedules the birth event before Pregnancy Visit 2" do
              contact = Factory(:contact, :contact_date_date => 24.days.ago(@due_date).to_date)
              contact_link = Factory(:contact_link, :contact => contact, :person => participant.person,
                :event => Factory(:event, :participant => participant))

              participant.pregnant_informed_consent!
              participant.pregnancy_one_visit!

              participant.next_study_segment.should == PatientStudyCalendar::CHILD_CHILD
              participant.next_scheduled_event.event.should == participant.next_study_segment
              participant.next_scheduled_event.date.should == @due_date + 1.days
            end
          end

          describe "where the contact is greater than 60 days before the due date" do
            it "schedules the Pregnancy Visit 2 event" do
              contact = Factory(:contact, :contact_date_date => 61.days.ago(@due_date).to_date)
              contact_link = Factory(:contact_link, :contact => contact, :person => participant.person,
                :event => Factory(:event, :participant => participant))

              participant.pregnant_informed_consent!
              participant.pregnancy_one_visit!

              participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_2
              participant.next_scheduled_event.event.should == participant.next_study_segment
              participant.next_scheduled_event.date.should == contact.contact_date_date + 60.days
            end
          end
        end
      end

    end

    context "a registered ppg2 participant" do

      let(:participant) { Factory(:high_intensity_ppg2_participant) }
      let(:person) { Factory(:person) }
      let(:date) { Date.parse("2000-01-09") }
      let(:event) { Factory(:event, :participant => participant,
                                    :event_start_date => date, :event_end_date => date,
                                    :event_type => NcsCode.pregnancy_screener) }

      before(:each) do
        participant.person = person
        participant.events << event

        contact = Factory(:contact, :contact_date_date => date)
        contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => person)
      end

      it "must first go through the LO-Intensity HI-LO Conversion event immediately" do
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == date
      end

      it "must consent to the High Intensity protocol" do
        participant.non_pregnant_informed_consent!
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_PRE_PREGNANCY
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == date
      end

      it "ends up in the followup loop after the pre-pregnancy interview" do
        participant.non_pregnant_informed_consent!
        participant.follow!
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == 3.months.since(date).to_date
      end

    end

    context "a registered ppg3 participant" do

      let(:participant) { Factory(:high_intensity_ppg3_participant) }
      let(:person) { Factory(:person) }
      let(:date) { Date.parse("2000-01-09") }
      let(:event) { Factory(:event, :participant => participant,
                                    :event_start_date => date, :event_end_date => date,
                                    :event_type => NcsCode.pregnancy_screener) }

      before(:each) do
        participant.person = person
        participant.events << event

        contact = Factory(:contact, :contact_date_date => date)
        contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => person)
      end

      it "must first go through the LO-Intensity HI-LO Conversion event immediately" do
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == date
      end

      it "goes into the High Intensity Follow Up loop every 6 months after consenting" do
        participant.high_intensity_conversion!
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == 6.months.since(date).to_date
      end

    end

    context "a registered ppg4 participant" do

      let(:participant) { Factory(:high_intensity_ppg4_participant) }
      let(:person) { Factory(:person) }
      let(:date) { Date.parse("2000-01-09") }
      let(:event) { Factory(:event, :participant => participant,
                                    :event_start_date => date, :event_end_date => date,
                                    :event_type => NcsCode.pregnancy_screener) }

      before(:each) do
        participant.person = person
        participant.events << event

        contact = Factory(:contact, :contact_date_date => date)
        contact_link = Factory(:contact_link, :contact => contact, :event => event, :person => person)
      end

      it "must first go through the LO-Intensity HI-LO Conversion event immediately" do
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == date
      end

      it "goes into the High Intensity Follow Up loop every 3 months after consenting" do
        participant.high_intensity_conversion!
        participant.next_study_segment.should == PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == 3.months.since(date).to_date
      end

    end

  end

end
