# -*- coding: utf-8 -*-


require 'spec_helper'

describe ApplicationHelper do

  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ApplicationHelper)
  end

  context "disposition codes" do
    it "returns grouped disposition codes" do
      helper.grouped_disposition_codes.include?("<optgroup label=").should be_true
    end
  end

  context "text" do
    describe ".blank_safe" do
      it "returns ___ if blank" do
        helper.blank_safe(nil).should == "___"
      end

      it "returns given replacement if blank" do
        helper.blank_safe(nil, "n/a").should == "n/a"
      end
    end

    describe ".instrument_name" do

      it "returns the human readable instrument name" do
        helper.instrument_name('INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0').should == 'Pregnancy Visit 1 Interview'
      end

      it 'accepts a default if human readable name not found' do
        helper.instrument_name('UNKNOWN', 'DEFAULT').should == 'DEFAULT'
      end

      it 'returns the parameter if no default provided' do
        helper.instrument_name('UNKNOWN').should == 'UNKNOWN'
      end

    end

  end

  context "limiting continue" do
    describe ".continuable?" do

      let(:continuable_event) { Factory(:event, :event_type_code => 10) } # Informed Consent
      let(:noncontinuable_event) { Factory(:event, :event_type_code => 23) } # 3 Month

      it "returns true if event type is a continuable event" do
        helper.continuable?(continuable_event).should be_true
      end

      it "returns false if event type is NOT a continuable event" do
        helper.continuable?(noncontinuable_event).should be_false
      end
    end
  end

end
