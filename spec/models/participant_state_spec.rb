# encoding: utf-8

require 'spec_helper'

describe Participant do

  before(:each) do
    psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    @uri  = psc_config["uri"]
    @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
  end

  let(:psc) { PatientStudyCalendar.new(@user) }
  let(:status1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 1: Pregnant", :local_code => 1) }
  let(:status2) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }
  let(:status4) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 4: Not Pregnant Not Trying", :local_code => 4) }

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

    it "should assign the participant into a pregnancy probability group" do
      participant.should be_registered
      psc.should_receive(:update_subject).with(participant).and_return(true)
      participant.update_state_after_survey(response_set, psc)
      participant.should be_in_pregnancy_probability_group
    end

    describe "who is in PPG 1 or 2" do

      it "requires consent" do
        participant = Factory(:participant, :low_intensity_state => 'registered')
        participant.should be_registered
        psc.should_receive(:update_subject).with(participant).and_return(true)
        participant.update_state_after_survey(response_set, psc)
        participant.should be_in_pregnancy_probability_group

        Factory(:ppg_detail, :participant => participant, :ppg_first => status2)

        participant.ppg_details.reload
        participant.ppg_details.should_not be_empty
        participant.ppg_status.should == status2

        participant.requires_consent.should be_true
      end

      it "administers the low intensity questionnaire as soon as possible" do
        participant = Factory(:participant, :low_intensity_state => 'consented_low_intensity')
        Factory(:ppg_detail, :participant => participant, :ppg_first => status2)

        participant.ppg_status.should == status2
        participant.should be_consented_low_intensity
        participant.should_take_low_intensity_questionnaire?.should be_true
      end

    end

  end

  context "after completing the Low Intensity Questionnaire Instrument" do

    let(:participant) { Factory(:participant, :low_intensity_state => 'in_pregnancy_probability_group') }
    let(:survey) { Factory(:survey, :title => "_LIPregNotPreg_") }
    let(:response_set) { Factory(:response_set, :survey => survey, :person => participant.person) }

    describe "in ppg 2 (trying)" do

      it "should be following the low intensity participant" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status2)
        participant.should be_in_pregnancy_probability_group
        participant.update_state_after_survey(response_set, psc)
        participant.should be_following_low_intensity
      end
    end

    describe "in ppg 1 (pregnant)" do

      it "should be following low intensity if the due_date > 6 mos" do

        due_date = 8.months.from_now

        Factory(:ppg_detail, :participant => participant, :ppg_first => status1, :orig_due_date => due_date.strftime('%Y-%m-%d'))

        participant.should be_in_pregnancy_probability_group
        participant.update_state_after_survey(response_set, psc)
        participant.should be_following_low_intensity

      end

      it "should be pregnant if the due_date < 6 mos" do
        due_date = 4.months.from_now

        Factory(:ppg_detail, :participant => participant, :ppg_first => status1, :orig_due_date => due_date.strftime("%m/%d/%Y"))

        participant.should be_in_pregnancy_probability_group
        participant.update_state_after_survey(response_set, psc)
        participant.should be_pregnant_low

      end

    end
  end

  context "after completing the Low to High Conversion" do

    let(:participant) { Factory(:participant, :low_intensity_state => 'in_pregnancy_probability_group') }

    let(:survey) { Factory(:survey, :title => "_LIHIConversion_") }
    let(:response_set) { Factory(:response_set, :survey => survey, :person => participant.person) }

    it "moves the participant into the high intensity arm" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2)
      participant.should be_in_pregnancy_probability_group
      participant.update_state_after_survey(response_set, psc)
      participant.should be_moved_to_high_intensity_arm
      participant.requires_consent.should be_true
    end

    describe "a non-pregnant participant" do
      it "requires non_pregnant informed consent" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status2)
        participant.should be_in_pregnancy_probability_group
        participant.update_state_after_survey(response_set, psc)
        participant.should be_pre_pregnancy
        participant.requires_consent.should be_true
      end
    end

    describe "a pregnant participant" do
      it "requires pregnant informed consent" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status1)
        participant.should be_in_pregnancy_probability_group
        participant.update_state_after_survey(response_set, psc)
        participant.should be_pregnancy_one
        participant.requires_consent.should be_true
      end
    end
  end

  context "after consenting to the high intensity arm" do

    let(:participant) { Factory(:participant, :low_intensity_state => 'moved_to_high_intensity_arm', :high_intensity_state => 'converted_high_intensity') }

    describe "a ppg 1 (pregnant) participant" do
      it "is the in the pregnancy_one state" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status1)
        participant.should be_converted_high_intensity
        participant.process_high_intensity_consent!
        participant.should be_pregnancy_one
      end
    end

    describe "a ppg 2 (trying) participant" do
      it "is the in the pre_pregnancy state" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status2)
        participant.should be_converted_high_intensity
        participant.process_high_intensity_consent!
        participant.should be_pre_pregnancy
      end
    end

    describe "a non ppg 1 or 2 participant" do
      it "is the in the following_high_intensity state" do
        Factory(:ppg_detail, :participant => participant, :ppg_first => status4)
        participant.should be_converted_high_intensity
        participant.process_high_intensity_consent!
        participant.should be_following_high_intensity
      end
    end

  end

  context "after completing the Pregnancy One Visit" do

    let(:participant) { Factory(:participant, :high_intensity_state => 'pregnancy_one') }

    let(:survey) { Factory(:survey, :title => "_PregVisit1_") }
    let(:response_set) { Factory(:response_set, :survey => survey, :person => participant.person) }

    describe "a high intensity pregnant participant" do
      it "moves to the high intensity pregnancy two state" do
        participant.should be_pregnancy_one
        participant.update_state_after_survey(response_set, psc)
        participant.should be_pregnancy_two
      end
    end

  end

  context "updating a participant state given an event type" do
    let(:person) { Factory(:person) }
    before(:each) do
      [
        [1, "Household Enumeration"],
        [2, "Two Tier Enumeration"],
        [3, "Ongoing Tracking of Dwelling Units"],
        [4, "Pregnancy Screening - Provider Group"],
        [5, "Pregnancy Screening – High Intensity  Group"],
        [6, "Pregnancy Screening – Low Intensity Group "],
        [7, "Pregnancy Probability"],
        [8, "PPG Follow-Up by Mailed SAQ"],
        [9, "Pregnancy Screening - Household Enumeration Group"],
        [10, "Informed Consent"],
        [11, "Pre-Pregnancy Visit"],
        [12, "Pre-Pregnancy Visit SAQ"],
        [13, "Pregnancy Visit  1"],
        [14, "Pregnancy Visit #1 SAQ"],
        [15, "Pregnancy Visit  2"],
        [16, "Pregnancy Visit #2 SAQ"],
        [17, "Pregnancy Visit - Low Intensity Group"],
        [18, "Birth"],
        [19, "Father"],
        [20, "Father Visit SAQ"],
        [21, "Validation"],
        [22, "Provider-Based Recruitment"],
        [23, "3 Month"],
        [24, "6 Month"],
        [25, "6-Month Infant Feeding SAQ"],
        [26, "9 Month"],
        [27, "12 Month"],
        [28, "12 Month Mother Interview SAQ"],
        [29, "Pregnancy Screener"],
        [30, "18 Month"],
        [31, "24 Month"],
        [32, "Low to High Conversion"],
        [33, "Low Intensity Data Collection"],
        [-5, "Other"],
        [-4, "Missing in Error"]
      ].each do |code, text|
        Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => text, :local_code => code)
      end
    end

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

      describe "given any Pregnancy Screener event" do
        it "should be in the in_pregnancy_probability_group state for Pregnancy Screener" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 29).first)
          participant.set_state_for_event_type(event)
          participant.should be_in_pregnancy_probability_group
        end

        it "should be in the in_pregnancy_probability_group state for Pregnancy Screening - Provider Group" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 4).first)
          participant.set_state_for_event_type(event)
          participant.should be_in_pregnancy_probability_group
        end

        it "should be in the in_pregnancy_probability_group state for Pregnancy Screening – High Intensity  Group" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 5).first)
          participant.set_state_for_event_type(event)
          participant.should be_in_pregnancy_probability_group
        end

        it "should be in the in_pregnancy_probability_group state for Pregnancy Screening – Low Intensity Group " do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 6).first)
          participant.set_state_for_event_type(event)
          participant.should be_in_pregnancy_probability_group
        end
      end

      describe "given Informed Consent" do
        it "should be in the consented_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 10).first)
          participant.set_state_for_event_type(event)
          participant.should be_consented_low_intensity
        end
      end

      describe "given Low Intensity Data Collection"

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
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 7).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_low_intensity
        end
      end

      describe "given PPG Follow-Up by Mailed SAQ" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 8).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_low_intensity
        end
      end

      describe "given Informed Consent" do
        it "should be in the consented_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 10).first)
          participant.set_state_for_event_type(event)
          participant.should be_consented_low_intensity
        end
      end

      describe "given Low Intensity Data Collection" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 33).first)
          participant.set_state_for_event_type(event)
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
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 29).first)
          participant.set_state_for_event_type(event)
          participant.should be_consented_low_intensity
        end
      end

      describe "given Low Intensity Data Collection" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 33).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_low_intensity
        end

        it "should be in the pregnant_low state if pregnant at the time of the event" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 33).first, :event_start_date => Date.today)
          pregnant_participant = Factory(:low_intensity_ppg1_participant)
          pregnant_participant.ppg_status.local_code.should == 1
          pregnant_participant.should be_pregnant
          pregnant_participant.set_state_for_event_type(event)
          pregnant_participant.should be_pregnant_low
        end

      end

      describe "given Pre-Pregnancy Visit" do
        it "should be in the following high intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 11).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_high_intensity
          participant.should be_high_intensity
        end

        it "should be in the pre_pregnancy state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 12).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_high_intensity
          participant.should be_high_intensity
        end
      end

      describe "given Pregnancy Probability" do
        it "should be in the pre_pregnancy state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 7).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_low_intensity
          participant.should be_low_intensity
        end

        it "should be in the pregnant_low state if pregnant at the time of the event" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 7).first, :event_start_date => Date.today)
          pregnant_participant = Factory(:low_intensity_ppg1_participant)
          pregnant_participant.ppg_status.local_code.should == 1
          pregnant_participant.should be_pregnant
          pregnant_participant.set_state_for_event_type(event)
          pregnant_participant.should be_pregnant_low
        end

      end

      describe "given Pregnancy Visit 1" do
        it "should be in the pregnancy_one state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 13).first)
          participant.set_state_for_event_type(event)
          participant.should be_pregnancy_one
          participant.should be_high_intensity
        end

        it "should be in the pregnancy_one state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 14).first)
          participant.set_state_for_event_type(event)
          participant.should be_pregnancy_one
          participant.should be_high_intensity
        end
      end

      describe "given Birth" do
        it "should be in the postnatal state" do
          status4a = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4: Not Pregnant Not Trying", :local_code => 4)
          Factory(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :local_code => -5)
          Factory(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :local_code => -5)

          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 18).first)
          participant.set_state_for_event_type(event)
          participant.should be_postnatal
          participant.ppg_status.should == status4a
        end
      end

      describe "given Pregnancy Visit 2" do
        it "should be in the pregnancy_two state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 15).first)
          participant.set_state_for_event_type(event)
          participant.should be_pregnancy_two
          participant.should be_high_intensity
        end

        it "should be in the pregnancy_two state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 16).first)
          participant.set_state_for_event_type(event)
          participant.should be_pregnancy_two
          participant.should be_high_intensity
        end
      end

      describe "given Low to High Conversion" do
        it "should be in the moved_to_high_intensity_arm state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 32).first)
          participant.set_state_for_event_type(event)
          participant.should be_high_intensity
          participant.should be_moved_to_high_intensity_arm
          participant.should be_in_high_intensity_arm
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
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 29).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_low_intensity
        end
      end

      describe "given Pregnancy Probability" do
        it "should be in the following_low_intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 7).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_low_intensity
          participant.should be_low_intensity
        end
      end

      describe "given Informed Consent" do
        it "should be in the following_high_intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 10).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_low_intensity
        end
      end

      describe "given Low to High Conversion" do
        it "should be in the moved_to_high_intensity_arm state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 32).first)
          participant.set_state_for_event_type(event)
          participant.should be_high_intensity
          participant.should be_moved_to_high_intensity_arm
          participant.should be_in_high_intensity_arm
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
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 7).first)
          participant.set_state_for_event_type(event)
          # participant.should be_pre_pregnancy
          # participant.should be_following_high_intensity
          # TODO: check if this happens in cases of loss
        end
      end

      describe "given Pregnancy Visit  1" do
        it "should be in the pregnancy_one state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 13).first)
          participant.set_state_for_event_type(event)
          participant.should be_pregnancy_one
        end
      end

    end

    context "with a participant in the pregnancy_one state" do
      let(:participant) { Factory(:participant, :high_intensity_state => "pregnancy_one", :high_intensity => true) }
      let(:person) { Factory(:person) }

      before(:each) do
        create_missing_in_error_ncs_codes PpgStatusHistory
        participant.person = person
        participant.should be_pregnancy_one
        participant.should be_high_intensity
      end

      # The known transitions from pregnancy_one are:
      # 4 :            Pregnancy Visit  1 -> Pregnancy Visit  2
      # 1 :            Pregnancy Visit  1 -> Birth

      describe "given Pregnancy Visit  2" do
        it "should be in the pregnancy_two state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 15).first)
          participant.set_state_for_event_type(event)
          participant.should be_pregnancy_two
        end
      end

      describe "given Birth" do
        it "should be in the parenthood state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 18).first)
          participant.set_state_for_event_type(event)
          participant.should be_parenthood
        end
      end

    end

    context "with a participant in the pregnancy_two state" do
      let(:participant) { Factory(:participant, :high_intensity_state => "pregnancy_two", :high_intensity => true) }
      let(:person) { Factory(:person) }

      before(:each) do
        create_missing_in_error_ncs_codes PpgStatusHistory
        participant.person = person
        participant.should be_pregnancy_two
        participant.should be_high_intensity
      end

      # The known transitions from pregnancy_one are:
      # 1 :            Pregnancy Visit  2 -> Birth

      describe "given Birth" do
        it "should be in the parenthood state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 18).first)
          participant.set_state_for_event_type(event)
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
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 11).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_high_intensity
        end
      end

      describe "given Pregnancy Visit  1" do
        it "should be in the pregnancy_one state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 13).first)
          participant.set_state_for_event_type(event)
          participant.should be_pregnancy_one
        end
      end

      describe "given Pregnancy Probability" do
        it "should be in the following_high_intensity state" do
          event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 7).first)
          participant.set_state_for_event_type(event)
          participant.should be_following_high_intensity
        end
      end
    end

    context "postnatal" do
      let(:participant) { Factory(:participant, :low_intensity_state => "moved_to_high_intensity_arm", :high_intensity => true) }
      let(:person) { Factory(:person) }

      let(:status1)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
      let(:status1a) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
      let(:status4)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4: Other Probability – Not Pregnancy and not Trying", :local_code => 4) }

      before(:each) do

        create_missing_in_error_ncs_codes(PpgStatusHistory)

        participant.person = person
        event = Factory(:event, :event_type => NcsCode.where("list_name = 'EVENT_TYPE_CL1' and local_code = ?", 13).first)
        participant.set_state_for_event_type(event)
        participant.should be_pregnancy_one

        Factory(:ppg_detail, :participant => participant, :ppg_first => status1a)
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)

        participant.ppg_details.should_not be_empty
        participant.ppg_status_histories.should_not be_empty
        participant.ppg_status.should == status1
        participant.ppg_status.should_not == status4
      end

      it "should update the ppg status to 4" do
        participant.birth_event!
        Participant.find(participant.id).ppg_status.should == status4
      end

      it "should not run the postnatal transitions in importer mode" do
        previous_status = participant.ppg_status
        Participant.importer_mode do
          participant.birth_event!
          Participant.find(participant.id).ppg_status.should == previous_status
        end
      end

    end

  end

end