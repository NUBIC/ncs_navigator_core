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

  context "sample root" do
    it "returns UKNOWN when sample does not satisfy the format with dash" do
      helper.sample_root_id('0').should == "UNKNOWN"
    end
    it "returns the prefix before dash" do
      helper.sample_root_id('AB1234567-AB10').should == "AB1234567"
    end
  end

  context "sample extenstion" do
    it "returns UNKNOWN when sample does not satisfy the format with dash" do
      helper.sample_extenstion('0').should == "UNKNOWN"
    end
    it "returns the prefix after dash" do
      helper.sample_extenstion('AB1234567-AB10').should == "AB10"
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

  describe "staff_name" do

    before do
      user = mock(Aker::User)
      user.stub!(:full_name => 'test_user', :identifiers => { :staff_id => "7bf06f11-4294-4b95-ae7f-37281bd9842b" })

      user2 = mock(Aker::User)
      user2.stub!(:full_name => 'test_user2', :identifiers => { :staff_id => "8bf09g77-5000-2d89-ag4k-37281bd6780e" })


      users_array = [user, user2]
      Aker.authority.stub!(:find_users).and_return(users_array)
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
