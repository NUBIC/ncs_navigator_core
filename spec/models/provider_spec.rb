# == Schema Information
# Schema version: 20120607203203
#
# Table name: providers
#
#  id                         :integer         not null, primary key
#  psu_code                   :integer         not null
#  provider_id                :string(36)      not null
#  provider_type_code         :integer         not null
#  provider_type_other        :string(255)
#  provider_ncs_role_code     :integer         not null
#  provider_ncs_role_other    :string(255)
#  practice_info_code         :integer         not null
#  practice_patient_load_code :integer         not null
#  practice_size_code         :integer         not null
#  public_practice_code       :integer         not null
#  provider_info_source_code  :integer         not null
#  provider_info_source_other :string(255)
#  provider_info_date         :date
#  provider_info_update       :date
#  provider_comment           :text
#  transaction_type           :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  name_practice              :string(100)
#  list_subsampling_code      :integer
#  proportion_weeks_sampled   :integer
#  proportion_days_sampled    :integer
#  sampling_notes             :string(1000)
#

require 'spec_helper'

describe Provider do
  it "should create a new instance given valid attributes" do
    provider = Factory(:provider)
    provider.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:provider_type) }
  it { should belong_to(:provider_ncs_role) }
  it { should belong_to(:practice_info) }
  it { should belong_to(:practice_patient_load) }
  it { should belong_to(:practice_size) }
  it { should belong_to(:public_practice) }
  it { should belong_to(:provider_info_source) }
  it { should belong_to(:list_subsampling) }

  it { should have_one(:address) }
  it { should have_many(:person_provider_links) }
  it { should have_many(:patients).through(:person_provider_links) }
  it { should have_many(:personnel_provider_links) }
  it { should have_many(:staff).through(:personnel_provider_links) }

  it { should have_many(:contact_links) }
  it { should have_many(:events).through(:contact_links) }
  it { should have_many(:contacts).through(:contact_links) }

  it { should have_many(:provider_logistics) }

  describe ".to_s" do
    it "returns the name_practice" do
      Factory(:provider, :name_practice => "expected").to_s.should == "expected"
    end

    it "returns an empty string if there is no name_practice" do
      Factory(:provider, :name_practice => nil).to_s.should == ""
    end
  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      provider = Factory(:provider)
      provider.public_id.should_not be_nil
      provider.provider_id.should == provider.public_id
      provider.provider_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      provider = Provider.new
      provider.psu_code = 20000030
      provider.save!

      obj = Provider.first
      obj.provider_type.local_code.should == -4
      obj.provider_ncs_role.local_code.should == -4
      obj.practice_info.local_code.should == -4
      obj.practice_patient_load.local_code.should == -4
      obj.practice_size.local_code.should == -4
      obj.public_practice.local_code.should == -4
      obj.provider_info_source.local_code.should == -4
    end
  end

  context ".personnel_provider_links" do

    describe ".primary_contact" do

      it "returns the person associated with the primary contact personnel_provider_link" do
        provider = Factory(:provider)
        ppl = Factory(:personnel_provider_link, :primary_contact => true, :provider => provider)
        provider.personnel_provider_links.reload
        provider.primary_contact.should_not be_nil
        provider.primary_contact.should == ppl.person
      end

      it "returns nil if there is no primary contact" do
        provider = Factory(:provider)
        provider.personnel_provider_links.should be_empty
        provider.primary_contact.should be_nil
      end

    end

  end

  context ".telephones" do

    describe ".telephone" do

      it "returns the associated telephone record with a phone type of work" do
        provider = Factory(:provider)
        phone    = Factory(:telephone, :provider => provider, :phone_type => Telephone.work_phone_type)
        provider.telephones.reload
        provider.telephones.should_not be_empty
        provider.telephone.should == phone
      end

      it "returns nil if there is no work phone" do
        provider = Factory(:provider)
        provider.telephones.should be_empty
        provider.telephone.should be_nil
      end

    end

    describe ".fax" do

      it "returns the associated telephone record with a phone type of fax" do
        provider = Factory(:provider)
        phone    = Factory(:telephone, :provider => provider, :phone_type => Telephone.fax_phone_type)
        provider.telephones.reload
        provider.telephones.should_not be_empty
        provider.fax.should == phone
      end

      it "returns nil if there is no fax phone" do
        provider = Factory(:provider)
        provider.telephones.should be_empty
        provider.telephone.should be_nil
      end

    end

  end

  context ".events" do

    describe ".provider_recruitment_event" do

      let(:provider) { Factory(:provider) }

      describe "when provider recruitment event has not started" do
        it "returns nil" do
          provider.provider_recruitment_event.should be_nil
        end
      end

      describe "when provider recruitment event has started" do

        let(:event) { Factory(:event, :event_type_code => 22) }

        before(:each) do
          link  = Factory(:contact_link, :provider => provider, :event => event)
        end

        it "returns the event with that event type" do
          provider.provider_recruitment_event.should == event
        end
      end

    end

  end

end
