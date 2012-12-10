require 'spec_helper'

describe InstitutionPersonLink do

  it "should create a new instance given valid attributes" do
    inst_pers_link = Factory(:institution_person_link)
    inst_pers_link.should_not be_nil
  end

  it { should belong_to(:institution) }
  it { should belong_to(:person) }
  it { should belong_to(:psu) }
  it { should belong_to(:is_active) }
  it { should belong_to(:institute_relation) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      ipl = Factory(:institution_person_link)
      ipl.public_id.should_not be_nil
      ipl.person_institute_id.should == ipl.public_id
      ipl.person_institute_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      ipl = InstitutionPersonLink.new
      ipl.person = Factory(:person)
      ipl.institution = Factory(:institution)
      ipl.save!

      obj = InstitutionPersonLink.first
      obj.is_active.local_code.should == -4
      obj.institute_relation.local_code.should == -4
    end
  end
end
