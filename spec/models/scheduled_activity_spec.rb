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
      :labels => "event:birth instrument:ins_que_birth_int_ehpbhi_p2_v2.0 order:01_01 participant_type:self"
    }
  end

  describe ".new" do
    it "accepts a hash as a parameter to the constructor" do
      ScheduledActivity.new(attrs).should_not be_nil
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

  context "understanding the labels" do

    let(:scheduled_activity) { ScheduledActivity.new(attrs) }

    describe ".participant_type" do
      it "extracts participant_type from the label" do
        scheduled_activity.participant_type.should == "self"
      end
    end

    describe ".event" do
      it "extracts event from the label" do
        scheduled_activity.event.should == "birth"
      end
    end

    describe ".order" do
      it "extracts order from the label" do
        scheduled_activity.order.should == "01_01"
      end
    end

    describe ".instrument" do
      it "extracts instrument from the label" do
        scheduled_activity.instrument.should == "ins_que_birth_int_ehpbhi_p2_v2.0"
      end
    end

  end

end