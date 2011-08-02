# == Schema Information
# Schema version: 20110727185512
#
# Table name: contacts
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  contact_id              :string(36)      not null
#  contact_disposition     :integer
#  contact_type_code       :integer         not null
#  contact_type_other      :string(255)
#  contact_date            :string(10)
#  contact_date_date       :date
#  contact_start_time      :string(255)
#  contact_end_time        :string(255)
#  contact_language_code   :integer         not null
#  contact_language_other  :string(255)
#  contact_interpret_code  :integer         not null
#  contact_interpret_other :string(255)
#  contact_location_code   :integer         not null
#  contact_location_other  :string(255)
#  contact_private_code    :integer         not null
#  contact_private_detail  :string(255)
#  contact_distance        :decimal(6, 2)
#  who_contacted_code      :integer         not null
#  who_contacted_other     :string(255)
#  contact_comment         :text
#  transaction_type        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

require 'spec_helper'

describe Contact do
  it "should create a new instance given valid attributes" do
    c = Factory(:contact)
    c.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:contact_type) }
  it { should belong_to(:contact_language) }
  it { should belong_to(:contact_interpret) }
  it { should belong_to(:contact_location) }
  it { should belong_to(:contact_private) }
  it { should belong_to(:who_contacted) }  
  
  context "as mdes record" do
    
    it "sets the public_id to a uuid" do
      c = Factory(:contact)
      c.public_id.should_not be_nil
      c.contact_id.should == c.public_id
      c.contact_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Contact)
      
      c = Contact.new
      c.psu = Factory(:ncs_code)
      c.save!
    
      obj = Contact.first
      obj.contact_type.local_code.should == -4
      obj.contact_language.local_code.should == -4
      obj.contact_interpret.local_code.should == -4
      obj.contact_location.local_code.should == -4
      obj.contact_private.local_code.should == -4
      obj.who_contacted.local_code.should == -4
    end
  end
  
end
