require 'spec_helper'

describe ScheduledActivity do

  def attrs
    {
      :study_segment => "HI-Intensity: Child",
      :activity_id => "activity_id",
      :current_state => "scheduled",
      :ideal_date => "2011-01-01",
      :date => "2011-01-01",
      :activity_name => "Birth Interview",
      :activity_type => "Instrument",
      :person_id => "asdf",
      :labels => "event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name order:01_02 participant_type:child references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0"
    }
  end

  describe ".new" do
    it "accepts a hash as a parameter to the constructor" do
      ScheduledActivity.new(attrs).should_not be_nil
    end
  end

  describe "occurred?" do
    let(:sa) { ScheduledActivity.new(attrs) }

    it "should be true if current_state is 'occurred'" do
      sa.current_state = Psc::ScheduledActivity::OCCURRED
      sa.should be_occurred
    end

    it "should be false if current_state is other than 'occurred'" do
      sa.should_not be_occurred
    end
  end

  describe "#saq_activity?" do

    it "returns true if activity_name ends with SAQ" do
      ScheduledActivity.new(:activity_name => "asdf SAQ").should be_saq_activity
    end

    it "returns false if activity_name does not end with SAQ" do
      ScheduledActivity.new(:activity_name => "asdf").should_not be_saq_activity
    end
  end


  describe "#open?" do
    let(:sa) { ScheduledActivity.new(attrs) }

    it "is true if scheduled" do
      sa.current_state = Psc::ScheduledActivity::SCHEDULED
      sa.should be_open
    end

    it "is true if conditional" do
      sa.current_state = Psc::ScheduledActivity::CONDITIONAL
      sa.should be_open
    end

    it "is false if occurred" do
      sa.current_state = Psc::ScheduledActivity::OCCURRED
      sa.should_not be_open
    end
  end

  describe "#closed?" do
    let(:sa) { ScheduledActivity.new(attrs) }

    it "is false if scheduled" do
      sa.current_state = Psc::ScheduledActivity::SCHEDULED
      sa.should_not be_closed
    end

    it "is false if conditional" do
      sa.current_state = Psc::ScheduledActivity::CONDITIONAL
      sa.should_not be_closed
    end

    it "is true if occurred" do
      sa.current_state = Psc::ScheduledActivity::OCCURRED
      sa.should be_closed
    end
  end

  describe ".consent_activity?" do
    it "is true if the ScheduledActivity.activity_type includes the word Consent" do
      ScheduledActivity.new(:activity_type => "Consent").should be_consent_activity
    end

    it "is false if the ScheduledActivity.activity_type does not include the word Consent" do
      ScheduledActivity.new(:activity_type => "Instrument").should_not be_consent_activity
    end

    it "is false if the ScheduledActivity.activity_type is blank" do
      ScheduledActivity.new(:activity_type => nil).should_not be_consent_activity
    end
  end

  describe "#child_consent?" do
    let(:sa) { ScheduledActivity.new(:activity_name => activity_name) }

    describe "for a Child Consent" do
      let(:activity_name) { "Child Consent" }
      it "is true" do
        sa.should be_child_consent
      end
    end

    describe "for a Child Consent Birth to 6 Months" do
      let(:activity_name) { "Child Consent Birth to 6 Months" }
      it "is true" do
        sa.should be_child_consent
      end
    end

    describe "for a Child Consent Birth to 6 Months to Age of Majority" do
      let(:activity_name) { "Child Consent 6 Months to Age of Majority" }
      it "is true" do
        sa.should be_child_consent
      end
    end

    describe "for a Pregnant Woman Informed Consent" do
      let(:activity_name) { "Pregnant Woman Informed Consent" }
      it "is false" do
        sa.should_not be_child_consent
      end
    end

  end

  context "understanding the labels" do

    let(:scheduled_activity) { ScheduledActivity.new(attrs) }

    describe ".participant_type" do
      it "extracts participant_type from the label" do
        scheduled_activity.participant_type.should == "child"
      end
    end

    describe ".event" do
      it "extracts event from the label" do
        scheduled_activity.event.should == "birth"
      end
    end

    describe ".order" do
      it "extracts order from the label" do
        scheduled_activity.order.should == "01_02"
      end
    end

    describe ".instrument" do
      it "extracts instrument from the label" do
        NcsNavigatorCore.mdes.stub(:version).and_return "2.0"
        scheduled_activity.instrument.should == "ins_que_birth_int_ehpbhi_p2_v2.0_baby_name"
      end
    end

    describe ".references" do
      it "extracts references from the label" do
        NcsNavigatorCore.mdes.stub(:version).and_return "2.0"
        scheduled_activity.references.should == "ins_que_birth_int_ehpbhi_p2_v2.0"
      end
    end

    describe ".references_collection" do
      it "extracts all references from the label" do
        sa = ScheduledActivity.new(:labels =>
          "event:pregnancy_visit_1 references:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0 references:3.0:ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0 order:01_01")
        sa.references_collection.size.should == 2
        sa.references_collection.should include("ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0")
        sa.references_collection.should include("ins_que_pregvisit1_int_ehpbhi_p2_v2.0")
      end

      context "mdes version 3.0" do
        it "sets the current mdes version as the references" do
          NcsNavigatorCore.mdes.stub(:version).and_return "3.0"
          sa = ScheduledActivity.new(:labels =>
            "event:pregnancy_visit_1 references:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0 references:3.0:ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0 order:01_01")

          sa.references.should == "ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0"
        end
      end

      context "mdes version 2.0" do
        it "sets the current mdes version as the references" do
          NcsNavigatorCore.mdes.stub(:version).and_return "2.0"
          sa = ScheduledActivity.new(:labels =>
            "event:pregnancy_visit_1 references:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0 references:3.0:ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0 order:01_01")

          sa.references.should == "ins_que_pregvisit1_int_ehpbhi_p2_v2.0"
        end

        it "does not set references if no matching mdes version references" do
          NcsNavigatorCore.mdes.stub(:version).and_return "2.0"
          sa = ScheduledActivity.new(:labels =>
            "event:pregnancy_visit_1 references:3.0:ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0 order:01_01")

          sa.references.should be_blank
        end

      end
    end

    describe ".instruments" do
      it "extracts all instruments from the label" do
        sa = ScheduledActivity.new(:labels =>
          "event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0 instrument:3.0:ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0 order:01_01")
        sa.instruments.size.should == 2
        sa.instruments.should include("ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0")
        sa.instruments.should include("ins_que_pregvisit1_int_ehpbhi_p2_v2.0")
      end

      context "mdes version 3.0" do
        it "sets the current mdes version as the instrument" do
          NcsNavigatorCore.mdes.stub(:version).and_return "3.0"
          sa = ScheduledActivity.new(:labels =>
            "event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0 instrument:3.0:ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0 order:01_01")

          sa.instrument.should == "ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0"
        end
      end

      context "mdes version 2.0" do
        it "sets the current mdes version as the instrument" do
          NcsNavigatorCore.mdes.stub(:version).and_return "2.0"
          sa = ScheduledActivity.new(:labels =>
            "event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0 instrument:3.0:ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0 order:01_01")

          sa.instrument.should == "ins_que_pregvisit1_int_ehpbhi_p2_v2.0"
        end

        it "does not set instrument if no matching mdes version instrument" do
          NcsNavigatorCore.mdes.stub(:version).and_return "2.0"
          sa = ScheduledActivity.new(:labels =>
            "event:pregnancy_visit_1 instrument:3.0:ins_que_pregvisit1_int_ehpbhi_m3.0_v3.0 order:01_01")

          sa.instrument.should be_blank
        end

      end
    end

  end

  describe "#survey_root" do

    let(:scheduled_activity) { ScheduledActivity.new(:labels => labels) }

    before do
      NcsNavigatorCore.mdes.stub(:version).and_return "9.9"
    end

    describe "for a form activity" do
      let(:form) { "the_form_survey_title" }
      let(:labels) { "form:9.9:#{form}" }
      it "returns the form: label value" do
        scheduled_activity.survey_root.should == form
      end
    end

    describe "for an instrument activity" do
      let(:instrument) { "the_instrument_survey_title" }
      let(:labels) { "instrument:9.9:#{instrument}" }
      it "returns the instrument: label value" do
        scheduled_activity.survey_root.should == instrument
      end
    end

  end

  context "sorting" do

    let(:sc1) { ScheduledActivity.new(:labels => "event:a order:01_01") }
    let(:sc2) { ScheduledActivity.new(:labels => "event:a order:01_02") }
    let(:sc3) { ScheduledActivity.new(:labels => "event:a") }

    describe ".<=>" do

      it "sorts by the order attribute" do
        (sc1.<=> sc2).should == -1
      end

      it "sorts" do
        [sc2, sc1].sort.should == [sc1, sc2]
      end

      it "places items without an explicit order at the end" do
        [sc3, sc2, sc1].sort.should == [sc1, sc2, sc3]
      end

    end

    context "with instruments" do

      let(:sc11) { ScheduledActivity.new(:labels => "order:01_01 instrument:1.0:A") }
      let(:sc12) { ScheduledActivity.new(:labels => "order:01_01 instrument:1.0:A.B") }

      before(:each) do
        NcsNavigatorCore.mdes.stub(:version).and_return "1.0"
      end

      describe ".<=>" do

        it "sorts by the order attribute then the instrument name" do
          (sc11.<=> sc12).should == -1
        end

        it "sorts" do
          [sc12, sc11].sort.should == [sc11, sc12]
        end

      end

    end

    context "with people" do

      let(:p1)   { Factory(:participant, :p_id => "a") }
      let(:p2)   { Factory(:participant, :p_id => "b") }

      let(:sc11) { ScheduledActivity.new(:labels => "order:01_01 instrument:1.0:X", :participant => p1) }
      let(:sc12) { ScheduledActivity.new(:labels => "order:01_01 instrument:1.0:X", :participant => p2) }

      describe ".<=>" do

        it "sorts by the order attribute, instrument name, then participant_id.p_id" do
          (sc11.<=> sc12).should == -1
        end

        it "sorts" do
          [sc12, sc11].sort.should == [sc11, sc12]
        end

      end

    end

  end

end