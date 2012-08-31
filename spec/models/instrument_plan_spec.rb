require 'spec_helper'

describe InstrumentPlan do

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
          plan.events.last.should  == '6m'
        end
      end

      describe ".instruments" do

        let(:plan) { InstrumentPlan.from_schedule(participant_plan) }

        it "knows all of the instruments for the participant" do
          plan.instruments.size.should == 5
        end

        it "orders the instruments by event and order label" do
          [
            'ins_que_birth_int_ehpbhi_p2_v2.0',
            'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name',
            'ins_que_3mmother_int_ehpbhi_p2_v1.1',
            'ins_que_6mmother_int_ehpbhi_p2_v1.1'
          ].each_with_index do |instrument, index|
            plan.instruments[index].should == instrument
          end
        end

        it "takes a String representing event as an optional parameter" do
          plan.instruments('birth').size.should == 2
          plan.instruments('3m').size.should == 1
        end

      end

      describe ".scheduled_activities_for_survey" do

        let(:plan) { InstrumentPlan.from_schedule(participant_plan) }

        it "returns all scheduled_activity parts for a given survey" do

          parts = plan.scheduled_activities_for_survey('ins_que_birth_int_ehpbhi_p2_v2.0_baby_name')
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

        it "knows all the instruments for the mother and child" do
          plan.instruments('6m').size.should == 2
        end

        it "knows all the scheduled activities for the mother and child" do
          plan.activities_for_event('6m').size.should == 2
        end

        it "knows the participant associated with the appropriate instrument" do
          activities = plan.activities_for_event('6m')
          mother_activity = activities.first
          mother_activity.instrument.should == 'ins_que_6mmother_int_ehpbhi_p2_v1.1'
          mother_activity.participant.should == mother

          child_activity = activities.last
          child_activity.instrument.should == 'ins_que_6minfantfeed_saq_ehpbhi_p2_v20'
          child_activity.participant.should == child
        end

        describe ".final_survey_part?" do

          let(:birth_event) { NcsCode.find_event_by_lbl('birth') }
          let(:event) { Factory(:event, :event_type => birth_event) }
          let(:instrument) { Factory(:instrument, :event => event) }
          let(:survey1) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0') }
          let!(:response_set1) { Factory(:response_set, :survey => survey1, :instrument => instrument,
                                                       :person => mp, :participant => mother) }
          let(:survey2) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name') }

          it "returns false if there is a next instrument" do
            plan.final_survey_part?(response_set1).should be_false
          end

          it "returns true if there is no next instrument and
              there are as many response_sets as there are scheduled_activities
              for the survey" do
            rs2 = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                         :person => mp, :participant => child)
            instrument.response_sets.reload
            plan.final_survey_part?(rs2).should be_true
          end

        end

        describe ".current_scheduled_activity" do

          let(:birth_event) { NcsCode.find_event_by_lbl('birth') }
          let(:event) { Factory(:event, :event_type => birth_event) }
          let(:instrument) { Factory(:instrument, :event => event) }
          let(:survey1) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0') }
          let(:survey2) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name') }

          it "returns the first scheduled_activity if the response_set is null" do
            csa = plan.current_scheduled_activity('6m')
            csa.survey_title.should == 'ins_que_6mmother_int_ehpbhi_p2_v1.1'
          end

          it "returns the first scheduled_activity that does not have a
              response_set associated with an instrument in the instrument_plan" do
            csa = plan.current_scheduled_activity('birth')
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0'

            rs = Factory(:response_set, :survey => survey1, :instrument => instrument,
                                        :person => mp, :participant => mother)


            instrument.response_sets.size.should == 1
            plan.current_survey_title('birth', rs).should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'

            csa = plan.current_scheduled_activity('birth', rs)
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'

            rs = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                        :person => mp, :participant => child)

            instrument.response_sets.reload
            instrument.response_sets.size.should == 2

            plan.current_survey_title('birth', rs).should be_nil

            csa = plan.current_scheduled_activity('birth', rs)
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

        it "knows all the instruments for the mother and child" do
          plan.instruments('6m').size.should == 3
        end

        it "knows all the scheduled activities for the mother and child" do
          plan.activities_for_event('6m').size.should == 3
        end

        it "knows the participant associated with the appropriate instrument" do
          activities = plan.activities_for_event('6m')
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
          let(:event) { Factory(:event, :event_type => birth_event) }
          let(:instrument) { Factory(:instrument, :event => event) }
          let(:survey1) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0') }
          let!(:response_set1) { Factory(:response_set, :survey => survey1, :instrument => instrument,
                                                        :person => mp, :participant => mother) }
          let(:survey2) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name') }
          let!(:response_set2) { Factory(:response_set, :survey => survey2, :instrument => instrument,
                                                        :person => mp, :participant => child1) }

          it "returns false if there is a next instrument" do
            plan.final_survey_part?(response_set1).should be_false
          end

          it "returns false if there is no next instrument and
              there are NOT as many response_sets as there are scheduled_activities
              for the survey" do
            plan.final_survey_part?(response_set2).should be_false
          end

          it "returns true if there is no next instrument and
              there are as many response_sets as there are scheduled_activities
              for the survey" do
            rs = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                        :person => mp, :participant => child2)
            instrument.response_sets.reload
            plan.final_survey_part?(rs).should be_true
          end

        end

        describe ".current_scheduled_activity" do

          let(:birth_event) { NcsCode.find_event_by_lbl('birth') }
          let(:event) { Factory(:event, :event_type => birth_event) }
          let(:instrument) { Factory(:instrument, :event => event) }
          let(:survey1) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0') }
          let(:survey2) { Factory(:survey, :title => 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name') }

          it "returns the first scheduled_activity if the response_set is null" do
            csa = plan.current_scheduled_activity('6m')
            csa.survey_title.should == 'ins_que_6mmother_int_ehpbhi_p2_v1.1'
          end

          it "returns the first scheduled_activity that does not have a
              response_set associated with an instrument in the instrument_plan" do

            plan.activities_for_event('birth').size.should == 4

            csa = plan.current_scheduled_activity('birth')
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0'

            rs = Factory(:response_set, :survey => survey1, :instrument => instrument,
                                        :person => mp, :participant => mother)
            plan.current_survey_title('birth', rs).should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'

            instrument.response_sets.size.should == 1

            csa = plan.current_scheduled_activity('birth', rs)
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'

            rs = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                        :person => mp, :participant => child1)
            plan.current_survey_title('birth', rs).should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'
            instrument.response_sets.reload
            instrument.response_sets.size.should == 2

            csa = plan.current_scheduled_activity('birth', rs)
            csa.survey_title.should == 'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'

            rs = Factory(:response_set, :survey => survey2, :instrument => instrument,
                                        :person => mp, :participant => child2)

            # FIXME: current_survey_title should handle multiple occurrances of a survey part
            # plan.current_survey_title('birth', rs).should be_nil
            instrument.response_sets.reload
            instrument.response_sets.size.should == 3

            csa = plan.current_scheduled_activity('birth', rs)
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

  context "moving through the plan" do

    let(:plan) { InstrumentPlan.from_schedule(participant_plan) }

    describe ".current_survey_title" do
      it "returns the first instrument if no response_set given" do
        plan.current_survey_title('6m').should == 'ins_que_6mmother_int_ehpbhi_p2_v1.1'
      end

      it "returns the next instrument after the current instrument" do
        instrument = Factory(:instrument)
        survey     = Factory(:survey, :title => 'ins_que_6mmother_int_ehpbhi_p2_v1.1')
        rs         = Factory(:response_set, :survey => survey, :instrument => instrument)
        plan.current_survey_title('6m', rs).should == 'ins_que_6minfantfeed_saq_ehpbhi_p2_v20'
      end

      context "with multiple children" do

        it "returns the first child instrument if no child instruments have been taken"

        it "returns the next child instrument after the current child instruments having been taken"

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

        before(:each) do
          mother.person = mp
          child.person = cp
          mother.save!
          child.save!
          Factory(:participant_person_link, :participant => mother, :person => cp, :relationship_code => 8)
        end

        let(:plan) { InstrumentPlan.from_schedule(participant_plan_xp2) }

        it "knows all the instruments for the mother and child" do
          plan.instruments('birth').size.should == 3
        end

        it "knows all the scheduled activities for the mother and child" do
          plan.activities_for_event('birth').size.should == 4
        end

        it "knows the participant associated with the appropriate instrument" do
          activities = plan.activities_for_event('birth')

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

        it "knows all the instruments for the mother and child" do
          plan.instruments('birth').size.should == 5
        end

        it "knows all the scheduled activities for the mother and child" do
          plan.activities_for_event('birth').size.should == 6
        end

        it "knows the participant associated with the appropriate instrument" do
          activities = plan.activities_for_event('birth')

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


  def participant_plan
    {
      'days' => {
        '2011-01-01' => {
          'activities' => [
            {
              'id' => '1',
              'activity' => { 'name' => 'Birth Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:ins_que_birth_int_ehpbhi_p2_v2.0 order:01_01 participant_type:self'
            },
            {
              'id' => '2',
              'activity' => { 'name' => 'Birth Interview Baby', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name order:01_02 participant_type:child references:ins_que_birth_int_ehpbhi_p2_v2.0'
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
              'labels' => 'event:3m instrument:ins_que_3mmother_int_ehpbhi_p2_v1.1'
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
              'labels' => 'event:6m instrument:ins_que_6mmother_int_ehpbhi_p2_v1.1 order:01_01 participant_type:self'
            },
            {
              'id' => '5',
              'activity' => { 'name' => '6-Month Infant Feed SAQ', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:6m instrument:ins_que_6minfantfeed_saq_ehpbhi_p2_v20 order:01_02 participant_type:child'
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
              'labels' => 'event:birth instrument:ins_que_birth_int_ehpbhi_p2_v2.0 order:01_01 participant_type:self'
            },
            {
              'id' => '12',
              'activity' => { 'name' => 'Birth Interview Baby', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:birth instrument:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name order:01_02 participant_type:child'
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
              'labels' => 'collection:biological event:birth instrument:ins_bio_cordblood_dci_ehpbhi_p2_v1.0 order:02_01 participant_type:child'
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
              'labels' => 'event:3m instrument:ins_que_3mmother_int_ehpbhi_p2_v1.1'
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
              'labels' => 'event:6m instrument:ins_que_6mmother_int_ehpbhi_p2_v1.1 order:01_01 participant_type:self'
            },
            {
              'id' => '32',
              'activity' => { 'name' => '6-Month Infant Feed SAQ', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'current_state' => { 'name' => 'scheduled' },
              'labels' => 'event:6m instrument:ins_que_6minfantfeed_saq_ehpbhi_p2_v20 order:01_02 participant_type:child'
            }

          ]
        }

      }
    }
  end


end
