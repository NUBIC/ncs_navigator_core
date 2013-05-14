# -*- coding: utf-8 -*-


require 'spec_helper'

describe Participant do

  before(:each) do
    psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    @uri  = psc_config["uri"]
    @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")
  end

  let(:psc) { PatientStudyCalendar.new(@user) }
  let(:status1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1) }
  let(:status2) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 2) }
  let(:status2_cl1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2) }
  let(:status4) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 4) }

  context "a new record" do

    let(:person) { Factory(:person) }

    it "starts in the pending state" do
      participant = Factory(:participant)
      person = Factory(:person)
      participant.person = person
      participant.should be_pending
    end

    it "registers with psc" do
      VCR.use_cassette('psc/assign_subject') do
        participant = Factory(:participant)
        person = Factory(:person)
        participant.person = person
        participant.should be_pending
        psc.should_receive(:is_registered?).and_return(false)
        psc.assign_subject(participant)
        participant.should be_registered
      end
    end

  end

  context "after completing the Pregnancy Screener Instrument" do

    let(:participant) { Factory(:participant, :low_intensity_state => 'registered') }
    let(:survey) { Factory(:survey, :title => "_PregScreen_") }
    let(:person) { Factory(:person) }
    let(:response_set) { Factory(:response_set, :survey => survey, :person => person) }

    describe "who is in PPG 1 or 2" do

      it "administers the low intensity questionnaire as soon as possible" do
        participant = Factory(:participant, :low_intensity_state => 'consented_low_intensity')
        Factory(:ppg_detail, :participant => participant, :ppg_first => status2)

        participant.ppg_status.should == status2_cl1
        participant.should be_consented_low_intensity
        participant.should_take_low_intensity_questionnaire?.should be_true
      end
    end
  end

  context "after consenting to the high intensity arm" do

    let(:participant) { Factory(:participant,
                                :low_intensity_state => 'moved_to_high_intensity_arm',
                                :high_intensity_state => 'converted_high_intensity') }

    describe "a ppg 1 (pregnant) participant" do
      it "is the in the pregnancy_one state" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status1)
        participant.should be_converted_high_intensity
        participant.process_high_intensity_conversion!
        participant.should be_pregnancy_one
      end
    end

    describe "a ppg 2 (trying) participant" do
      it "is the in the pre_pregnancy state" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status2)
        participant.should be_converted_high_intensity
        participant.process_high_intensity_conversion!
        participant.should be_pre_pregnancy
      end
    end

    describe "a non ppg 1 or 2 participant" do
      it "is the in the following_high_intensity state" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status4)
        participant.should be_converted_high_intensity
        participant.process_high_intensity_conversion!
        participant.should be_following_high_intensity
      end
    end

  end

  context "updating a participant state given an event type" do
    let(:person) { Factory(:person) }

    context "moving to an invalid state" do
      let(:participant) { Factory(:participant, :person => person) }

      describe "a new participant" do
        it "should raise an InvalidTransition exception when given an out of sequence event"
      end
    end

    context "correctly initializing a new participant" do

      # The known starting events are:
      # 1249:                       [start] -> Pregnancy Screener
      #   8 :                       [start] -> Informed Consent
      #   2 :                       [start] -> Low Intensity Data Collection

      let(:participant) { Factory(:participant) }
      let(:person) { Factory(:person) }

      before(:each) do
        participant.person = person
        participant.should be_pending
      end

      describe "given any Household Event" do
        it "should not change the participant state" do
          participant.low_intensity_state = 'in_pregnancy_probability_group'
          participant.should be_in_pregnancy_probability_group
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 1))
          participant.set_state_for_imported_event(event)
          participant.should be_in_pregnancy_probability_group
        end
      end

      describe "given any Pregnancy Screener event" do
        it "should be in the in_pregnancy_probability_group state for Pregnancy Screener" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 29))
          participant.set_state_for_imported_event(event)
          participant.should be_in_pregnancy_probability_group
        end

        it "should be in the in_pregnancy_probability_group state for Pregnancy Screening - Provider Group" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 4))
          participant.set_state_for_imported_event(event)
          participant.should be_in_pregnancy_probability_group
        end

        it "should be in the in_pregnancy_probability_group state for Pregnancy Screening – High Intensity  Group" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 5))
          participant.set_state_for_imported_event(event)
          participant.should be_in_pregnancy_probability_group
        end

        it "should be in the in_pregnancy_probability_group state for Pregnancy Screening – Low Intensity Group " do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 6))
          participant.set_state_for_imported_event(event)
          participant.should be_in_pregnancy_probability_group
        end
      end
    end

    context "with a participant in the in_pregnancy_probability_group state" do

      # The known transitions from in_pregnancy_probability_group are:
      # 295 :            Pregnancy Screener -> Pregnancy Probability
      #  45 :            Pregnancy Screener -> Informed Consent
      #   2 :            Pregnancy Screener -> Low Intensity Data Collection

      let(:participant) { Factory(:participant, :low_intensity_state => "in_pregnancy_probability_group") }
      let(:person) { Factory(:person) }

      before(:each) do
        participant.person = person
        participant.should be_in_pregnancy_probability_group
        Factory(:ppg_detail, :participant => participant, :ppg_first => status2)
      end

      describe "given Pregnancy Probability" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7))
          participant.set_state_for_imported_event(event)
          participant.should be_following_low_intensity
        end
      end

      describe "given PPG Follow-Up by Mailed SAQ" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 8))
          participant.set_state_for_imported_event(event)
          participant.should be_following_low_intensity
        end

        it "should not move within the high intensity state machine arm" do
          participant.should be_low_intensity
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 8))
          participant.set_state_for_imported_event(event)
          participant.should_not be_following_high_intensity
        end
      end

      describe "given Low Intensity Data Collection" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 33))
          participant.set_state_for_imported_event(event)
          participant.should be_following_low_intensity
        end
      end

    end

    context "with a participant in the consented_low_intensity state" do
      let(:participant) { Factory(:participant, :low_intensity_state => "consented_low_intensity") }
      let(:person) { Factory(:person) }

      before(:each) do
        participant.person = person
        participant.should be_consented_low_intensity
      end

      # The known transitions from consented_low_intensity are:
      #    5 :              Informed Consent -> Pre-Pregnancy Visit
      #    4 :              Informed Consent -> Pregnancy Visit  1
      #    1 :              Informed Consent -> Pregnancy Visit  2
      #    1 :              Informed Consent -> Birth
      #    3 :              Informed Consent -> Pregnancy Screener
      #   26 :              Informed Consent -> Low Intensity Data Collection
      #    3 :              Informed Consent -> Pregnancy Probability
      #   10 :              Informed Consent -> Low to High Conversion

      describe "given Pregnancy Screener" do
        it "should be in the consented_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 29))
          participant.set_state_for_imported_event(event)
          participant.should be_consented_low_intensity
        end
      end

      describe "given Low Intensity Data Collection" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 33))
          participant.set_state_for_imported_event(event)
          participant.should be_following_low_intensity
        end

        it "should be in the pregnant_low state if pregnant at the time of the event" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 33), :event_start_date => Date.today)
          pregnant_participant = Factory(:low_intensity_ppg1_participant)
          pregnant_participant.ppg_status.local_code.should == 1
          pregnant_participant.should be_pregnant
          pregnant_participant.set_state_for_imported_event(event)
          pregnant_participant.should be_pregnant_low
        end

      end

      describe "given Pre-Pregnancy Visit" do
        it "does nothing" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 11))
          participant.set_state_for_imported_event(event)
          participant.should be_consented_low_intensity
        end
      end

      describe "given Pregnancy Probability" do
        it "should be in the pre_pregnancy state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7))
          participant.set_state_for_imported_event(event)
          participant.should be_following_low_intensity
          participant.should be_low_intensity
        end

        it "should be in the pregnant_low state if pregnant at the time of the event" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7), :event_start_date => Date.today)
          pregnant_participant = Factory(:low_intensity_ppg1_participant)
          pregnant_participant.ppg_status.local_code.should == 1
          pregnant_participant.should be_pregnant
          pregnant_participant.set_state_for_imported_event(event)
          pregnant_participant.should be_pregnant_low
        end

      end

      describe "given Pregnancy Visit 1" do
        it "does nothing" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 13))
          participant.set_state_for_imported_event(event)
          participant.should be_consented_low_intensity
        end
      end

      describe "given Birth" do
        it "should be in the postnatal state" do
          status4a = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 4)

          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 18))
          participant.set_state_for_imported_event(event)
          participant.should be_postnatal
          participant.ppg_status.should == status4a
        end
      end

      describe "given Pregnancy Visit 2" do
        it "does nothing" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 15))
          participant.set_state_for_imported_event(event)
          participant.should be_consented_low_intensity
        end
      end

    end

    context "with a participant in the following_low_intensity state" do
      let(:participant) { Factory(:participant, :low_intensity_state => "following_low_intensity") }
      let(:person) { Factory(:person) }

      before(:each) do
        participant.person = person
        participant.should be_following_low_intensity
      end

      # The known transitions from following_low_intensity are:
      # 14 : Low Intensity Data Collection -> Informed Consent
      #  2 : Low Intensity Data Collection -> Pregnancy Screener
      #  1 : Low Intensity Data Collection -> Pregnancy Probability
      #  1 : Low Intensity Data Collection -> Low to High Conversion
      #  2 :         Pregnancy Probability -> Informed Consent

      describe "given Pregnancy Screener" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 29))
          participant.set_state_for_imported_event(event)
          participant.should be_following_low_intensity
        end
      end

      describe "given Pregnancy Probability" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7))
          participant.set_state_for_imported_event(event)
          participant.should be_following_low_intensity
          participant.should be_low_intensity
        end
      end

      describe "given Informed Consent" do
        it "should be in the following_high_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 10))
          participant.set_state_for_imported_event(event)
          participant.should be_following_low_intensity
        end
      end

    end

    context "with a participant in the pre_pregnancy state" do
      let(:participant) { Factory(:participant, :high_intensity_state => "pre_pregnancy", :high_intensity => true) }
      let(:person) { Factory(:person) }

      before(:each) do
        participant.person = person
        participant.should be_pre_pregnancy
        participant.should be_high_intensity
      end

      # The known transitions from pre_pregnancy are:
      # 1 :           Pre-Pregnancy Visit -> Pregnancy Visit  1
      # 2 :           Pre-Pregnancy Visit -> Pregnancy Probability

      describe "given Pregnancy Probability" do
        it "should be in the following_high_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7))
          participant.set_state_for_imported_event(event)
          # participant.should be_pre_pregnancy
          # participant.should be_following_high_intensity
          # TODO: check if this happens in cases of loss
        end
      end

      describe "given Pregnancy Visit  1" do
        it "should be in the pregnancy_one state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 13))
          participant.set_state_for_imported_event(event)
          participant.should be_pregnancy_one
        end
      end

    end

    context "with a participant in the pregnancy_one state" do
      let(:participant) { Factory(:participant, :high_intensity_state => "pregnancy_one", :high_intensity => true) }
      let(:person) { Factory(:person) }

      before(:each) do
        participant.person = person
        participant.should be_pregnancy_one
        participant.should be_high_intensity
      end

      # The known transitions from pregnancy_one are:
      # 4 :            Pregnancy Visit  1 -> Pregnancy Visit  2
      # 1 :            Pregnancy Visit  1 -> Birth

      describe "given Pregnancy Visit  2" do
        it "should be in the pregnancy_two state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 15))
          participant.set_state_for_imported_event(event)
          participant.should be_pregnancy_two
        end
      end

      describe "given Birth" do
        it "should be in the parenthood state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 18))
          participant.set_state_for_imported_event(event)
          participant.should be_parenthood
        end
      end

    end

    context "with a participant in the pregnancy_two state" do
      let(:participant) { Factory(:participant, :high_intensity_state => "pregnancy_two", :high_intensity => true) }
      let(:person) { Factory(:person) }

      before(:each) do
        participant.person = person
        participant.should be_pregnancy_two
        participant.should be_high_intensity
      end

      # The known transitions from pregnancy_one are:
      # 1 :            Pregnancy Visit  2 -> Birth

      describe "given Birth" do
        it "should be in the parenthood state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 18))
          participant.set_state_for_imported_event(event)
          participant.should be_parenthood
        end
      end

    end

    context "with a participant recently added to the high intensity arm" do
      let(:participant) { Factory(:participant, :low_intensity_state => "moved_to_high_intensity_arm", :high_intensity => true) }
      let(:person) { Factory(:person) }

      before(:each) do
        participant.person = person
        participant.should be_moved_to_high_intensity_arm
        participant.should be_in_high_intensity_arm
        participant.should be_high_intensity
      end

      # THe known transitions from moved_to_high_intensity_arm/in_high_intensity_arm are:
      # 4 :        Low to High Conversion -> Pre-Pregnancy Visit
      # 6 :        Low to High Conversion -> Pregnancy Visit  1
      # 1 :        Low to High Conversion -> Pregnancy Probability

      describe "given Pre-Pregnancy Visit" do
        it "should be in the pre_pregnancy state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 11))
          participant.set_state_for_imported_event(event)
          participant.should be_following_high_intensity
        end
      end

      describe "given Pregnancy Visit  1" do
        it "should be in the pregnancy_one state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 13))
          participant.set_state_for_imported_event(event)
          participant.should be_pregnancy_one
        end
      end

      describe "given Pregnancy Probability" do
        it "should be in the following_high_intensity state" do
          event = Factory(:event, :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7))
          participant.set_state_for_imported_event(event)
          participant.should be_following_high_intensity
        end
      end
    end

    context "postnatal" do
      let(:participant) { Factory(:participant, :low_intensity_state => "moved_to_high_intensity_arm", :high_intensity => true) }
      let(:person) { Factory(:person) }

      let(:status1)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1) }
      let(:status1a) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1) }
      let(:status4)  { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 4) }

      before(:each) do
        participant.person = person
        event = Factory(:event,
          :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 13))
        participant.set_state_for_imported_event(event)
        participant.should be_pregnancy_one

        Factory(:ppg_detail, :participant => participant, :ppg_first => status1a,
          :desired_history_date => '2010-01-01')
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)

        pt = Participant.find(participant.id)
        pt.ppg_details.should_not be_empty
        pt.ppg_status_histories.should_not be_empty
        pt.ppg_status.should == status1
        pt.ppg_status.should_not == status4
        @previous_status = pt.ppg_status
      end

      it "should update the ppg status to 4" do
        participant.birth_event!
        Participant.find(participant.id).ppg_status.should == status4
      end

      it "should not run the postnatal transitions in importer mode" do
        Participant.importer_mode do
          participant.birth_event!
          Participant.find(participant.id).ppg_status.should == @previous_status
        end
      end

    end

  end

end
