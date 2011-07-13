# == Schema Information
# Schema version: 20110624163825
#
# Table name: people
#
#  id                             :integer         not null, primary key
#  psu_code                       :string(36)      not null
#  prefix_code                    :integer         not null
#  first_name                     :string(30)
#  last_name                      :string(30)
#  middle_name                    :string(30)
#  maiden_name                    :string(30)
#  suffix_code                    :integer         not null
#  title                          :string(5)
#  sex_code                       :integer
#  age                            :integer
#  age_range_code                 :integer         not null
#  person_dob                     :string(10)
#  date_of_birth                  :date
#  deceased_code                  :integer         not null
#  ethnic_group_code              :integer         not null
#  language_code                  :integer         not null
#  language_other                 :string(255)
#  marital_status_code            :integer         not null
#  marital_status_other           :string(255)
#  preferred_contact_method_code  :integer         not null
#  preferred_contact_method_other :string(255)
#  planned_move_code              :integer         not null
#  move_info_code                 :integer         not null
#  when_move_code                 :integer         not null
#  moving_date                    :date
#  date_move                      :string(255)
#  p_tracing_code                 :integer         not null
#  p_info_source_code             :integer         not null
#  p_info_source_other            :string(255)
#  p_info_date                    :date
#  p_info_update                  :date
#  person_comment                 :text
#  transaction_type               :string(36)
#  created_at                     :datetime
#  updated_at                     :datetime
#

require 'spec_helper'

describe Person do

  it "should create a new instance given valid attributes" do
    pers = Factory(:person)
    pers.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:prefix) }
  it { should belong_to(:suffix) }
  it { should belong_to(:sex) }
  it { should belong_to(:age_range) }
  it { should belong_to(:deceased) }
  it { should belong_to(:ethnic_group) }
  it { should belong_to(:language) }
  it { should belong_to(:marital_status) }
  it { should belong_to(:preferred_contact_method) }
  it { should belong_to(:planned_move) }
  it { should belong_to(:move_info) }
  it { should belong_to(:when_move) }
  it { should belong_to(:p_tracing) }
  it { should belong_to(:p_info_source) }

  # Cannot use these shoulda macros when setting a default value for the attribute (missing in error)
  # 
  # it { should validate_presence_of(:psu) }
  # it { should validate_presence_of(:prefix) }
  # it { should validate_presence_of(:suffix) }
  # it { should validate_presence_of(:sex) }
  # it { should validate_presence_of(:age_range) }
  # it { should validate_presence_of(:deceased) }
  # it { should validate_presence_of(:ethnic_group) }
  # it { should validate_presence_of(:language) }
  # it { should validate_presence_of(:marital_status) }
  # it { should validate_presence_of(:preferred_contact_method) }
  # it { should validate_presence_of(:planned_move) }
  # it { should validate_presence_of(:move_info) }
  # it { should validate_presence_of(:when_move) }
  # it { should validate_presence_of(:p_tracing) }
  # it { should validate_presence_of(:p_info_source) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  
  context "With NCS Codes" do
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Person)
      
      pers = Person.new
      pers.psu = Factory(:ncs_code)
      pers.first_name = "John"
      pers.last_name = "Doe"
      pers.save!
    
      Person.first.prefix.local_code.should == -4
      Person.first.suffix.local_code.should == -4
    end
  end

end
