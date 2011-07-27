# == Schema Information
# Schema version: 20110726214159
#
# Table name: contact_links
#
#  id               :integer         not null, primary key
#  psu_code         :integer         not null
#  contact_link_id  :string(36)      not null
#  contact_id       :integer         not null
#  event_id         :integer
#  instrument_id    :integer
#  staff_id         :string(36)      not null
#  person_id        :integer
#  provider_id      :integer
#  transaction_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe ContactLink do

  it "should create a new instance given valid attributes" do
    link = Factory(:contact_link)
    link.should_not be_nil
  end

  
  it { should belong_to(:psu) }
  it { should belong_to(:contact) }
  it { should belong_to(:person) }
  it { should belong_to(:event) }
  it { should belong_to(:instrument) }
  # it { should belong_to(:provider) }

  it { should validate_presence_of(:staff_id) }
  it { should validate_presence_of(:contact) }
  
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      link = Factory(:contact_link)
      link.public_id.should_not be_nil
      link.contact_link_id.should == link.public_id
      link.contact_link_id.length.should == 36
    end

  end

end
