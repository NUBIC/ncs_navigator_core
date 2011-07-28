# == Schema Information
# Schema version: 20110727185512
#
# Table name: participants
#
#  id                       :integer         not null, primary key
#  psu_code                 :string(36)      not null
#  p_id                     :binary          not null
#  person_id                :integer         not null
#  p_type_code              :integer         not null
#  p_type_other             :string(255)
#  status_info_source_code  :integer         not null
#  status_info_source_other :string(255)
#  status_info_mode_code    :integer         not null
#  status_info_mode_other   :string(255)
#  status_info_date         :date
#  enroll_status_code       :integer         not null
#  enroll_date              :date
#  pid_entry_code           :integer         not null
#  pid_entry_other          :string(255)
#  pid_age_eligibility_code :integer         not null
#  pid_comment              :text
#  transaction_type         :string(36)
#  created_at               :datetime
#  updated_at               :datetime
#

require 'spec_helper'

describe Participant do
  
  it "should create a new instance given valid attributes" do
    par = Factory(:participant)
    par.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:person) }
  it { should belong_to(:p_type) }
  it { should belong_to(:status_info_source) }
  it { should belong_to(:status_info_mode) }
  it { should belong_to(:enroll_status) }
  it { should belong_to(:pid_entry) }
  it { should belong_to(:pid_age_eligibility) }

  it { should validate_presence_of(:person) }
  
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      pr = Factory(:participant)
      pr.public_id.should_not be_nil
      pr.p_id.should == pr.public_id
      pr.p_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Participant)
      
      pr = Participant.new
      pr.psu = Factory(:ncs_code)
      pr.person = Factory(:person)
      pr.save!
    
      obj = Participant.first
      obj.status_info_source.local_code.should == -4
      obj.pid_entry.local_code.should == -4
      obj.p_type.local_code.should == -4
      obj.status_info_source.local_code.should == -4
      obj.status_info_mode.local_code.should == -4
      obj.enroll_status.local_code.should == -4
      obj.pid_entry.local_code.should == -4
      obj.pid_age_eligibility.local_code.should == -4
    end
  end
  
  it "should return the participant's age" do
    pers = Factory(:person, :person_dob_date => 10.years.ago)
    pr = Factory(:participant, :person => pers)
    pr.age.should == 10
  end
  
end
