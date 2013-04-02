require 'spec_helper'

describe InstrumentPlan do

  before(:each) do
    NcsNavigatorCore.mdes.stub(:version).and_return "2.0"
  end

  describe ".from_schedule" do

    it "raises an exception if no parameter is sent to constructor" do
      lambda { InstrumentPlan.from_schedule }.should raise_error
    end

    it "accepts a hash as a parameter" do
      InstrumentPlan.from_schedule(participant_plan).should_not be_nil
    end

    describe "building the plan" do

      describe ".events" do
        it "orders the events" do
          plan = InstrumentPlan.from_schedule(participant_plan)

          plan.events.size.should  == 3
          plan.events.first.should == 'birth'
          plan.events.last.should  == '6_month'
        end
      end

      describe ".occurred_activities_for_event" do
        let(:event) { Factory(:event, :event_type_code => Event.pregnancy_visit_1_code, :event_start_date => Date.parse('2010-12-01'))}
        it "returns all the occurred_activities for the particular event if event is specified" do
          occurred_activities = InstrumentPlan.from_schedule(participant_plan).occurred_activities_for_event(event)
          occurred_activities.size.should  == 2
        end
      end

      describe ".scheduled_activities_for_survey" do
        let(:event) { Factory(:event, :event_type_code => Event.birth_code, :event_start_date => Date.parse('2011-01-01'))}
        let(:plan) { InstrumentPlan.from_schedule(participant_plan) }

        it "returns all scheduled_activity parts for a given survey" do
          parts = plan.scheduled_activities_for_survey('ins_que_birth_int_ehpbhi_p2_v2.0_baby_name', event)
          parts.size.should == 2
          parts.first.instrument.should == 'ins_que_birth_int_ehpbhi_p2_v2.0'
          parts.last.instrument.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'
        end

      end
    end
  end

  context "for a Participant" do

    describe ".from_schedule" do

      describe "for a mother with one child" do

        let(:mother) { Factory(:high_intensity_postnatal_participant) }
        let(:mp) { Factory(:person, :person_id => "mother") }
        let(:child) { Factory(:participant) }
        let(:cp) { Factory(:person, :person_id => "child") }

        before(:each) do
          mother.person = mp
          child.person = cp
          mother.save!
          child.save!
          Factory(:participant_person_link, :participant => mother, :person => cp, :relationship_code => 8)
        end

        let(:plan) { InstrumentPlan.from_schedule(participant_plan) }
        let(:birth_event_start_date) { Date.parse('2011-01-01') }

        describe ".final_survey_part?" do

          let(:birth_event) { NcsCode.find_event_by_lbl('birth') }
          let(:event) { Factory(:event, :event_type => birth_event, :event_start_date => birth_event_start_date) }
          let(:instrument) { Factory(:instrument, :event => event) }
          let(:survey1) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0') }
          let!(:response_set1) { Factory(:response_set, :survey => survey1, :instrument => instrument,
                                                       :person => mp, :participant => mother) }
          let(:survey2) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name') }

          it "returns false if there is a next instrument" do
            plan.final_survey_part?(response_set1, event).should be_false
          end

          it "returns true if there is no next instrument and
              there are as many response_sets as there are scheduled_activities
              for the survey" do
            rs2 = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                         :person => mp, :participant => child)
            instrument.response_sets.reload
            plan.final_survey_part?(rs2, event).should be_true
          end

        end

        describe ".current_scheduled_activity" do

          let(:birth_event) { NcsCode.find_event_by_lbl('birth') }
          let(:event) { Factory(:event, :event_type => birth_event, :event_start_date => birth_event_start_date) }
          let(:instrument) { Factory(:instrument, :event => event) }
          let(:survey1) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0') }
          let(:survey2) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name') }

          it "returns the first scheduled_activity if the response_set is null" do
            csa = plan.current_scheduled_activity(event, nil)
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0'
          end

          it "returns the first scheduled_activity that does not have a
              response_set associated with an instrument in the instrument_plan" do
            rs = Factory(:response_set, :survey => survey1, :instrument => instrument,
                                        :person => mp, :participant => mother)

            instrument.response_sets.size.should == 1

            csa = plan.current_scheduled_activity(event, rs)
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'

            rs = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                        :person => mp, :participant => child)

            instrument.response_sets.reload
            instrument.response_sets.size.should == 2

            csa = plan.current_scheduled_activity(event, rs)
            csa.instrument.should be_nil
            csa.activity_name.should == "Birth Visit Information Sheet"
          end

        end

      end

      describe "for a mother with two children" do
        let(:mother) { Factory(:high_intensity_postnatal_participant) }
        let(:mp) { Factory(:person, :person_id => "mother") }
        let(:child1) { Factory(:participant, :p_id => "child1") }
        let(:cp1) { Factory(:person, :person_id => "child1") }
        let(:child2) { Factory(:participant, :p_id => "child2") }
        let(:cp2) { Factory(:person, :person_id => "child2") }

        let(:event6m) { Factory(:event, :event_type_code => 24, :event_start_date => Date.parse('2011-07-01')) }

        before(:each) do
          mother.person = mp
          child1.person = cp1
          child2.person = cp2
          mother.save!
          child1.save!
          child2.save!
          Factory(:participant_person_link, :participant => mother, :person => cp1, :relationship_code => 8)
          Factory(:participant_person_link, :participant => mother, :person => cp2, :relationship_code => 8)
        end

        let(:plan) { InstrumentPlan.from_schedule(participant_plan) }
        let(:birth_event_start_date) { Date.parse('2011-01-01') }

        it "knows all the scheduled activities for the mother and child" do
          plan.scheduled_activities_for_event(event6m).size.should == 3
        end

        it "knows the participant associated with the appropriate instrument" do
          activities = plan.scheduled_activities_for_event(event6m)
          mother_activity = activities[0]
          mother_activity.instrument.should == 'ins_que_6mmother_int_ehpbhi_p2_v1.1'
          mother_activity.participant.should == mother

          child1_activity = activities[1]
          child1_activity.instrument.should == 'ins_que_6minfantfeed_saq_ehpbhi_p2_v20'
          child1_activity.participant.should == child1

          child2_activity = activities[2]
          child2_activity.instrument.should == 'ins_que_6minfantfeed_saq_ehpbhi_p2_v20'
          child2_activity.participant.should == child2
        end


        describe ".final_survey_part?" do

          let(:birth_event) { NcsCode.find_event_by_lbl('birth') }
          let(:event) { Factory(:event, :event_type => birth_event, :event_start_date => birth_event_start_date) }
          let(:instrument) { Factory(:instrument, :event => event) }
          let(:survey1) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0') }
          let!(:response_set1) { Factory(:response_set, :survey => survey1, :instrument => instrument,
                                                        :person => mp, :participant => mother) }
          let(:survey2) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name') }
          let!(:response_set2) { Factory(:response_set, :survey => survey2, :instrument => instrument,
                                                        :person => mp, :participant => child1) }

          it "returns false if there is a next instrument" do
            plan.final_survey_part?(response_set1, event).should be_false
          end

          it "returns false if there is no next instrument and
              there are NOT as many response_sets as there are scheduled_activities
              for the survey" do
            plan.final_survey_part?(response_set2, event).should be_false
          end

          it "returns true if there is no next instrument and
              there are as many response_sets as there are scheduled_activities
              for the survey" do
            rs = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                        :person => mp, :participant => child2)
            instrument.response_sets.reload
            plan.final_survey_part?(rs, event).should be_true
          end

        end

        describe ".current_scheduled_activity" do

          let(:birth_event) { NcsCode.find_event_by_lbl('birth') }
          let(:event) { Factory(:event, :event_type => birth_event, :event_start_date => birth_event_start_date) }
          let(:instrument) { Factory(:instrument, :event => event) }
          let(:survey1) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0') }
          let(:survey2) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name') }

          it "returns the first scheduled_activity if the response_set is null" do
            csa = plan.current_scheduled_activity(event, nil)
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0'
          end

          it "returns the first scheduled_activity that does not have a
              response_set associated with an instrument in the instrument_plan" do

            plan.scheduled_activities_for_event(event).size.should == 4

            rs = Factory(:response_set, :survey => survey1, :instrument => instrument,
                                        :person => mp, :participant => mother)

            instrument.response_sets.size.should == 1

            csa = plan.current_scheduled_activity(event, rs)
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'

            rs = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                        :person => mp, :participant => child1)
            instrument.response_sets.reload
            instrument.response_sets.size.should == 2

            csa = plan.current_scheduled_activity(event, rs)
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'

            rs = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                        :person => mp, :participant => child2)

            instrument.response_sets.reload
            instrument.response_sets.size.should == 3

            csa = plan.current_scheduled_activity(event, rs)
            csa.instrument.should be_nil
            csa.activity_name.should == "Birth Visit Information Sheet"
          end

        end

      end

      context "at the birth event" do

        describe "for a mother who just had one child"

        describe "for a mother who just had two children"

      end

    end
  end

  context "specimen collection" do
    describe ".new" do

      describe "for a mother with one child" do

        let(:mother) { Factory(:high_intensity_postnatal_participant) }
        let(:mp) { Factory(:person, :person_id => "mother") }
        let(:child) { Factory(:participant) }
        let(:cp) { Factory(:person, :person_id => "child") }

        let(:event_type) { NcsCode.find_event_by_lbl('birth') }
        let(:birth_event) { Factory(:event, :event_type => event_type, :event_start_date => Date.parse('2011-01-01')) }

        before(:each) do
          mother.person = mp
          child.person = cp
          mother.save!
          child.save!
          Factory(:participant_person_link, :participant => mother, :person => cp, :relationship_code => 8)
        end

        let(:plan) { InstrumentPlan.from_schedule(participant_plan_xp2) }

        it "knows all the scheduled activities for the mother and child" do
          plan.scheduled_activities_for_event(birth_event).size.should == 4
        end

        it "knows the participant associated with the appropriate instrument" do
          activities = plan.scheduled_activities_for_event(birth_event)

          mother_activity = activities[0]
          mother_activity.instrument.should == 'ins_que_birth_int_ehpbhi_p2_v2.0'
          mother_activity.participant.should == mother

          child_activity1 = activities[1]
          child_activity1.instrument.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'
          child_activity1.participant.should == child

          child_activity2 = activities[2]
          child_activity2.instrument.should == 'ins_bio_cordblood_dci_ehpbhi_p2_v1.0'
          child_activity2.participant.should == child

          activities[3].instrument.should be_nil
          activities[3].activity_name.should == "Birth Visit Information Sheet"
          activities[3].participant.should == mother
        end

      end

      describe "for a mother with two children" do
        let(:mother) { Factory(:high_intensity_postnatal_participant) }
        let(:mp) { Factory(:person, :person_id => "mother") }
        let(:child1) { Factory(:participant, :p_id => "child1") }
        let(:cp1) { Factory(:person, :person_id => "child1") }
        let(:child2) { Factory(:participant, :p_id => "child2") }
        let(:cp2) { Factory(:person, :person_id => "child2") }

        let(:event_type) { NcsCode.find_event_by_lbl('birth') }
        let(:birth_event) { Factory(:event, :event_type => event_type, :event_start_date => Date.parse('2011-01-01')) }

        before(:each) do
          mother.person = mp
          child1.person = cp1
          child2.person = cp2
          mother.save!
          child1.save!
          child2.save!
          Factory(:participant_person_link, :participant => mother, :person => cp1, :relationship_code => 8)
          Factory(:participant_person_link, :participant => mother, :person => cp2, :relationship_code => 8)
        end

        let(:plan) { InstrumentPlan.from_schedule(participant_plan_xp2) }

        it "knows the participant associated with the appropriate instrument" do
          activities = plan.scheduled_activities_for_event(birth_event)

          mother_activity = activities[0]
          mother_activity.instrument.should == 'ins_que_birth_int_ehpbhi_p2_v2.0'
          mother_activity.participant.should == mother

          child1_activity1 = activities[1]
          child1_activity1.instrument.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'
          child1_activity1.participant.should == child1

          child2_activity1 = activities[2]
          child2_activity1.instrument.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'
          child2_activity1.participant.should == child2

          child1_activity2 = activities[3]
          child1_activity2.instrument.should == 'ins_bio_cordblood_dci_ehpbhi_p2_v1.0'
          child1_activity2.participant.should == child1

          child2_activity2 = activities[4]
          child2_activity2.instrument.should == 'ins_bio_cordblood_dci_ehpbhi_p2_v1.0'
          child2_activity2.participant.should == child2

          activities[5].instrument.should be_nil
          activities[5].activity_name.should == "Birth Visit Information Sheet"
          activities[5].participant.should == mother
        end

      end

    end

  end

  context "finding scheduled activities" do

    let(:plan) { InstrumentPlan.from_schedule(find_scheduled_activity_plan) }
    let(:birth_event_start_date) { Date.parse('2011-07-01') }
    let(:ic_event_start_date) { Date.parse('2010-12-01') }
    let(:informed_consent_event_type) { NcsCode.find_event_by_lbl('informed_consent') }
    let(:birth_event_type)            { NcsCode.find_event_by_lbl('birth') }
    let(:birth_event)                 { Factory(:event, :event_type => birth_event_type, :event_start_date => birth_event_start_date) }
    let(:informed_consent_event)      { Factory(:event, :event_type => informed_consent_event_type, :event_start_date => ic_event_start_date) }

    before do
      NcsNavigatorCore.mdes.stub!(:version).and_return("3.0")
      @survey_title = 'ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one'
      @event = 'birth'
    end

    describe "#scheduled_activity_for_survey" do
      describe "for the informed consent event" do
        it "returns first scheduled activity matching title" do
          activity = plan.scheduled_activity_for_survey(@survey_title, informed_consent_event)
          activity.event.should == "informed_consent"
        end
      end

      describe "for the birth event" do
        it "returns first scheduled activity matching title" do
          activity = plan.scheduled_activity_for_survey(@survey_title, birth_event)
          activity.event.should == "birth"
        end
      end
    end

    describe "#scheduled_activities_for_survey" do

      describe "for the informed consent event" do
        it "returns all scheduled_activities for the given survey title and event" do
          plan.scheduled_activities_for_survey('ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one', informed_consent_event).count.should == 2
        end
      end

      describe "for the birth event" do
        it "returns all scheduled_activities for the given survey title and event" do
          plan.scheduled_activities_for_survey('ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one', birth_event).count.should == 2
        end
      end
    end

    describe "#final_survey_part?" do
      let(:birth_instrument)            { Factory(:instrument, :event => birth_event) }
      let(:informed_consent_instrument) { Factory(:instrument, :event => informed_consent_event) }
      let(:part_verif_part_1_in_birth_event_survey)             { Factory(:survey, :title => 'ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one') }
      let(:part_verif_part_2_in_birth_event_survey)             { Factory(:survey, :title => 'ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_two') }
      let(:part_verif_part_1_in_informed_consent_event_survey)  { Factory(:survey, :title => 'ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one') }
      let(:part_verif_part_2_in_informed_consent_event_survey)  { Factory(:survey, :title => 'ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_two') }
      let!(:birth_response_set1) { Factory(:response_set, :survey => part_verif_part_1_in_birth_event_survey, :instrument => birth_instrument) }
      let!(:informed_consent_response_set1) { Factory(:response_set, :survey => part_verif_part_1_in_informed_consent_event_survey, :instrument => informed_consent_instrument) }
      let(:participant_consent_response_set) { Factory(:response_set, :participant_consent => Factory(:participant_consent)) }
      let(:nir_response_set) { Factory(:response_set, :non_interview_report => Factory(:non_interview_report)) }

      it "returns false if, with a scoping event parameter, there a more scheduled activities for that event than there are response sets" do
        plan.final_survey_part?(birth_response_set1, birth_event).should be_false
      end

      it "returns true if, with an appropriate scoping event parameter, there are equal or greater response sets present than there are scheduled activities for a given event" do
        birth_response_set2 = Factory(:response_set, :survey => part_verif_part_2_in_birth_event_survey, :instrument => birth_instrument)
        plan.final_survey_part?(birth_response_set2, birth_event).should be_true
      end

      it "returns true if the ResponseSet is associated with a ParticipantConsent" do
        plan.final_survey_part?(participant_consent_response_set, birth_event).should be_true
      end

      it "returns true if the ResponseSet is associated with a NonInterviewReport" do
        plan.final_survey_part?(nir_response_set, birth_event).should be_true
      end

    end
  end

  def participant_plan
    {
      'days' => {
        '2010-12-01' => {
          'activities' => [
            {
              'id' => '51',
              'activity' => { 'name' => 'Pregnancy Visit 1 Interview', 'type' => 'Instrument' },
              'ideal_date' => '2010-12-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'occurred' },
              'labels' => 'event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0 order:01_01 participant_type:mother'
            },
            {
              'id' => '52',
              'activity' => { 'name' => 'Pregnancy Visit 1 SAQ', 'type' => 'Instrument' },
              'ideal_date' => '2010-12-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'occurred' },
              'labels' => 'event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_saq_ehpbhi_p2_v2.0 order:02_01 participant_type:mother '
            }
          ]
        },
        '2010-12-15' => {
          'activities' => [
            {
              'id' => '53',
              'activity' => { 'name' => 'Pregnancy Visit 2 Interview', 'type' => 'Instrument' },
              'ideal_date' => '2010-12-15',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'occurred' },
              'labels' => 'event:pregnancy_visit_2 instrument:2.0:ins_que_pregvisit2_int_ehpbhi_p2_v2.0 order:01_01 participant_type:mother'
            }
          ]
        },
        '2011-01-01' => {
          'activities' => [
            {
              'id' => '1',
              'activity' => { 'name' => 'Birth Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0 order:01_01 participant_type:mother'
            },
            {
              'id' => '2',
              'activity' => { 'name' => 'Birth Interview Baby', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name order:01_02 participant_type:child references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0'
            },
            {
              'id' => '3',
              'activity' => { 'name' => 'Birth Visit Information Sheet' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth'
            }
          ]
        },
        '2011-04-01' => {
          'activities' => [
            {
              'id' => '4',
              'activity' => { 'name' => '3-Month Mother Phone Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-04-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:3_month instrument:2.0:ins_que_3mmother_int_ehpbhi_p2_v1.1 participant_type:mother'
            }
          ]
        },
        '2011-07-01' => {
          'activities' => [
            {
              'id' => '5',
              'activity' => { 'name' => '6-Month Mother Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:6_month instrument:2.0:ins_que_6mmother_int_ehpbhi_p2_v1.1 order:01_01 participant_type:mother'
            },
            {
              'id' => '5',
              'activity' => { 'name' => '6-Month Infant Feed SAQ', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:6_month instrument:2.0:ins_que_6minfantfeed_saq_ehpbhi_p2_v20 order:01_02 participant_type:child'
            }

          ]
        }

      }
    }
  end

  def participant_plan_xp2
    {
      'days' => {
        '2011-01-01' => {
          'activities' => [
            {
              'id' => '11',
              'activity' => { 'name' => 'Birth Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0 order:01_01 participant_type:mother'
            },
            {
              'id' => '12',
              'activity' => { 'name' => 'Birth Interview Baby', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name order:01_02 participant_type:child'
            },
            {
              'id' => '13',
              'activity' => { 'name' => 'Birth Visit Information Sheet' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth'
            },
            {
              'id' => '14',
              'activity' => { 'name' => 'Biospecimen Cord Blood Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'collection:biological event:birth instrument:2.0:ins_bio_cordblood_dci_ehpbhi_p2_v1.0 order:02_01 participant_type:child'
            }
          ]
        },
        '2011-04-01' => {
          'activities' => [
            {
              'id' => '21',
              'activity' => { 'name' => '3-Month Mother Phone Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-04-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:3_month instrument:2.0:ins_que_3mmother_int_ehpbhi_p2_v1.1'
            }
          ]
        },
        '2011-07-01' => {
          'activities' => [
            {
              'id' => '31',
              'activity' => { 'name' => '6-Month Mother Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:6_month instrument:2.0:ins_que_6mmother_int_ehpbhi_p2_v1.1 order:01_01 participant_type:mother'
            },
            {
              'id' => '32',
              'activity' => { 'name' => '6-Month Infant Feed SAQ', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:6_month instrument:2.0:ins_que_6minfantfeed_saq_ehpbhi_p2_v20 order:01_02 participant_type:child'
            }

          ]
        }

      }
    }
  end

  def find_scheduled_activity_plan
    {
      'days' => {
        '2010-12-01' => {
          'activities' => [
            {
              'id' => '1',
              'activity' => { 'name' => 'Participant Verification Part One', 'type' => 'Instrument' },
              'ideal_date' => '2010-12-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:informed_consent instrument:3.0:ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one order:00_01 participant_type:mother'
            },
            {
              'id' => '2',
              'activity' => { 'name' => 'Participant Verification Part Two', 'type' => 'Instrument' },
              'ideal_date' => '2010-12-01',
              'assignment' => { 'id' => 'child'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:informed_consent instrument:3.0:ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_two order:00_01 participant_type:child references:3.0:ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one'
            },
            {
              'id' => '3',
              'activity' => { 'name' => 'Informed Consent', 'type' => 'Instrument' },
              'ideal_date' => '2010-12-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:informed_consent order:01_01 participant_type:mother'
            },
            {
              'id' => '4',
              'activity' => { 'name' => 'Parental Permission for Child Participation', 'type' => 'Instrument' },
              'ideal_date' => '2010-12-01',
              'assignment' => { 'id' => 'child'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:informed_consent order:01_01 participant_type:child'
            }
          ]
        },
        '2011-04-01' => {
          'activities' => [
            {
              'id' => '5',
              'activity' => { 'name' => '3-Month Mother Phone Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-04-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:3_month instrument:2.0:ins_que_3mmother_int_ehpbhi_p2_v1.1 participant_type:mother'
            }
          ]
        },
        '2011-07-01' => {
          'activities' => [
            {
              'id' => '6',
              'activity' => { 'name' => 'Participant Verification Part One', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:3.0:ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one order:00_01 participant_type:mother'
            },
            {
              'id' => '7',
              'activity' => { 'name' => 'Participant Verification Part Two', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'child'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:3.0:ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_two order:00_02 participant_type:child references:3.0:ins_que_participantverif_dci_ehpbhilipbs_m3.0_v1.0_part_one'
            },
            {
              'id' => '8',
              'activity' => { 'name' => 'Birth Interview Part 1', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_part_one instrument:2.1:ins_que_birth_int_ehpbhi_p2_v2.0_part_one instrument:2.2:ins_que_birth_int_ehpbhi_p2_v2.0_part_one instrument:3.0:ins_que_birth_int_ehpbhipbs_m3.0_v3.0_part_one order:01_01 participant_type:mother'
            },
            {
              'id' => '9',
              'activity' => { 'name' => 'Birth Interview Baby Name', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'child'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_birth_visit_baby_name instrument:2.1:ins_que_birth_int_ehpbhi_p2_v2.0_birth_visit_baby_name instrument:2.2:ins_que_birth_int_ehpbhi_p2_v2.0_birth_visit_baby_name instrument:3.0:ins_que_birth_int_ehpbhipbs_m3.0_v3.0_birth_visit_baby_name_3 order:01_02 participant_type:child references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_part_one references:2.1:ins_que_birth_int_ehpbhi_p2_v2.0_part_one references:2.2:ins_que_birth_int_ehpbhi_p2_v2.0_part_one references:3.0:ins_que_birth_int_ehpbhipbs_m3.0_v3.0_part_one'
            },
            {
              'id' => '10',
              'activity' => { 'name' => 'Birth Interview Part 2', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_part_two instrument:2.1:ins_que_birth_int_ehpbhi_p2_v2.0_part_two instrument:2.2:ins_que_birth_int_ehpbhi_p2_v2.0_part_two instrument:3.0:ins_que_birth_int_ehpbhipbs_m3.0_v3.0_part_two order:01_03 participant_type:mother references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_part_one references:2.1:ins_que_birth_int_ehpbhi_p2_v2.0_part_one references:2.2:ins_que_birth_int_ehpbhi_p2_v2.0_part_one references:3.0:ins_que_birth_int_ehpbhipbs_m3.0_v3.0_part_one'
            }
          ]
        }
      }
    }
  end


end
