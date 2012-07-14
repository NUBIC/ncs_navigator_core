require 'spec_helper'

describe InstrumentPlan do

  def plan
    {
      'days' => {
        '2011-01-01' => {
          'activities' => [
            {
              'id' => '1',
              'activity' => { 'name' => 'Birth Interview', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'labels' => 'event:birth instrument:ins_que_birth_int_ehpbhi_p2_v2.0 order:01_01 participant_type:self'
            },
            {
              'id' => '2',
              'activity' => { 'name' => 'Birth Interview Baby', 'type' => 'Instrument' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
              'labels' => 'event:birth instrument:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name order:01_02 participant_type:child'
            },
            {
              'id' => '3',
              'activity' => { 'name' => 'Birth Visit Information Sheet' },
              'ideal_date' => '2011-01-01',
              'assignment' => { 'id' => 'mother'},
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
              'labels' => 'event:6m instrument:ins_que_6mmother_int_ehpbhi_p2_v1.1 order:01_01 participant_type:self'
            },
            {
              'id' => '5',
              'activity' => { 'name' => '6-Month Infant Feed SAQ', 'type' => 'Instrument' },
              'ideal_date' => '2011-07-01',
              'assignment' => { 'id' => 'mother'},
              'labels' => 'event:6m instrument:ins_que_6minfantfeed_saq_ehpbhi_p2_v20 order:01_02 participant_type:child'
            }

          ]
        }

      }
    }
  end

  describe ".new" do

    it "raises an exception if no parameter is sent to constructor" do
      lambda { InstrumentPlan.new }.should raise_error
    end

    it "accepts a hash as a parameter" do
      InstrumentPlan.new(plan).should_not be_nil
    end

    describe "building the plan" do

      describe ".events" do
        it "orders the events" do
          instrument_plan = InstrumentPlan.new(plan)
          instrument_plan.events.size.should  == 3
          instrument_plan.events.first.should == 'birth'
          instrument_plan.events.last.should  == '6m'
        end
      end

      describe ".instruments" do

        let(:instrument_plan) { InstrumentPlan.new(plan) }

        it "knows all of the instruments for the participant" do
          instrument_plan.instruments.size.should == 5
        end

        it "orders the instruments by event and order label" do
          [
            'ins_que_birth_int_ehpbhi_p2_v2.0',
            'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name',
            'ins_que_3mmother_int_ehpbhi_p2_v1.1',
            'ins_que_6mmother_int_ehpbhi_p2_v1.1'
          ].each_with_index do |instrument, index|
            instrument_plan.instruments[index].should == instrument
          end
        end

        it "takes a String representing event as an optional parameter" do
          instrument_plan.instruments('birth').size.should == 2
          instrument_plan.instruments('3m').size.should == 1
        end

      end
    end
  end

  context "for a Participant" do

    describe ".new" do

      describe "for a mother with one child" do

        let(:mother) { Factory(:high_intensity_postnatal_participant) }
        let(:mp) { Factory(:person, :person_id => "mother") }
        let(:child) { Factory(:participant) }
        let(:cp) { Factory(:person, :person_id => "child") }

        before(:each) do
          mother.person = mp
          child.person = cp
          Factory(:participant_person_link, :participant => mother, :person => cp, :relationship_code => 8)
        end

        it "knows all the activities for the mother and child" do
          instrument_plan = InstrumentPlan.new(plan)
          instrument_plan.instruments('6m').size.should == 2
        end

      end

      describe "for a mother with two children"

      context "at the birth event" do

        describe "for a mother who just had one child"

        describe "for a mother who just had one child"

      end


    end

  end

  context "moving through the plan" do

    let(:instrument_plan) { InstrumentPlan.new(plan) }

    describe ".next_instrument" do
      it "returns the first instrument if no current instrument given" do
        instrument_plan.next_instrument('6m').should == 'ins_que_6mmother_int_ehpbhi_p2_v1.1'
      end

      it "returns the next instrument after the current instrument" do
        instrument_plan.next_instrument('6m', 'ins_que_6mmother_int_ehpbhi_p2_v1.1').should == 'ins_que_6minfantfeed_saq_ehpbhi_p2_v20'
      end
    end

  end

end