require File.dirname(__FILE__) + '/../spec_helper'

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

end