# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: providers
#
#  created_at                 :datetime
#  id                         :integer          not null, primary key
#  institution_id             :integer
#  list_subsampling_code      :integer
#  name_practice              :string(100)
#  practice_info_code         :integer          not null
#  practice_patient_load_code :integer          not null
#  practice_size_code         :integer          not null
#  proportion_days_sampled    :integer
#  proportion_weeks_sampled   :integer
#  provider_comment           :text
#  provider_id                :string(36)       not null
#  provider_info_date         :date
#  provider_info_source_code  :integer          not null
#  provider_info_source_other :string(255)
#  provider_info_update       :date
#  provider_ncs_role_code     :integer          not null
#  provider_ncs_role_other    :string(255)
#  provider_type_code         :integer          not null
#  provider_type_other        :string(255)
#  psu_code                   :integer          not null
#  public_practice_code       :integer          not null
#  sampling_notes             :string(1000)
#  transaction_type           :string(255)
#  updated_at                 :datetime
#

require 'spec_helper'

describe Provider do
  it "should create a new instance given valid attributes" do
    provider = Factory(:provider)
    provider.should_not be_nil
  end

  it { should belong_to(:institution) }

  it { should have_one(:address) }
  it { should have_many(:person_provider_links) }
  it { should have_many(:patients).through(:person_provider_links) }
  it { should have_many(:personnel_provider_links) }
  it { should have_many(:staff).through(:personnel_provider_links) }

  it { should have_many(:contact_links) }
  it { should have_many(:events).through(:contact_links) }
  it { should have_many(:contacts).through(:contact_links) }

  it { should have_many(:provider_logistics) }

  it { should have_one(:pbs_list) }
  it { should have_one(:substitute_pbs_list) }

  it { should have_many(:non_interview_providers) }

  it { should have_many(:pbs_provider_roles) }
  it { should have_many(:provider_roles) }

  it { should have_many(:person_provider_links) }
  it { should have_many(:people).through(:person_provider_links) }

  it { should ensure_length_of(:name_practice).is_at_most(100) }

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

  context "pbs_list" do

    let(:p1) { Factory(:provider, :name_practice => "1") }
    let(:p2) { Factory(:provider, :name_practice => "2") }
    let(:p3) { Factory(:provider, :name_practice => "3") }
    let(:p4) { Factory(:provider, :name_practice => "4") }
    let(:p5) { Factory(:provider, :name_practice => "5") }

    before(:each) do
      Factory(:pbs_list, :provider_id => p1.id, :in_sample_code => '1')
      Factory(:pbs_list, :provider_id => p2.id, :in_sample_code => '2')
      Factory(:pbs_list, :provider_id => p3.id, :in_sample_code => '1')
      Factory(:pbs_list, :provider_id => p4.id, :in_sample_code => '2')
      Factory(:pbs_list, :provider_id => p5.id, :in_sample_code => '1')
    end

    describe ".original_in_sample_providers" do

      it "returns all providers whose pbs_list record in_sample value is 1 (original sample provider location)" do
        original_providers = Provider.original_in_sample_providers
        original_providers.size.should == 3
        [p1, p3, p5].each { |provider| original_providers.should include provider }
      end

    end

    describe ".substitute_in_sample_providers" do

      it "returns all providers whose pbs_list record in_sample value is 2 (substitute sample provider location)" do
        sub_providers = Provider.substitute_in_sample_providers
        sub_providers.size.should == 2
        [p2, p4].each { |provider| sub_providers.should include provider }
      end

    end

  end

  context "provider logistics" do

    let(:provider) { Factory(:provider) }

    describe ".recruitment_logistics_complete?" do

      it "returns false if there are no provider logistics" do
        provider.provider_logistics.should be_empty
        provider.recruitment_logistics_complete?.should be_false
      end

      it "returns false if there are provider logistics but at least one does not have a completion date set" do
        [
          Factory(:provider_logistic, :completion_date => Date.today, :provider => provider),
          Factory(:provider_logistic, :completion_date => nil, :provider => provider)
        ].each do |logistic|
          provider.provider_logistics << logistic
        end

        provider.provider_logistics.should_not be_empty
        provider.provider_logistics.size.should == 2
        provider.recruitment_logistics_complete?.should be_false
      end

      it "returns true if all provider logistics have a completion date set" do
        logistic = Factory(:provider_logistic, :completion_date => Date.today, :provider => provider)
        provider.provider_logistics << logistic

        provider.provider_logistics.should_not be_empty
        provider.recruitment_logistics_complete?.should be_true
      end

    end

  end

end

