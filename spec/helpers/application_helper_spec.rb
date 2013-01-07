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
  
  describe "staffname" do  

    before do
      user = mock(Aker::User)
      user.stub!(:full_name => 'test_user', :identifiers => { :staff_id => "7bf06f11-4294-4b95-ae7f-37281bd9842b" })

      user2 = mock(Aker::User)
      user2.stub!(:full_name => 'test_user2', :identifiers => { :staff_id => "8bf09g77-5000-2d89-ag4k-37281bd6780e" })


      users_array = [user, user2]
      x = Object.new
      NcsNavigator::Authorization::Core::Authority.stub!(:new).and_return(x)
      x.stub!(:find_users).and_return(users_array)
    end

    it "should display full_name if the staff_id is present in staff_list" do
      helper.staff_name("7bf06f11-4294-4b95-ae7f-37281bd9842b").should eq("test_user")
    end

    it "returns an empty string if given an empty string" do
      helper.staff_name("").should eq("")
    end

    it "returns an empty string if given nil" do
      helper.staff_name(nil).should eq("")
    end
  end
   
end
