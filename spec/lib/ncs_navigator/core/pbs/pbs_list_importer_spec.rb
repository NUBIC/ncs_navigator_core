# -*- coding: utf-8 -*-


require 'spec_helper'

module NcsNavigator::Core::Pbs
  describe PbsListImporter do

    context "uploading csv data" do

      describe ".import_data" do

        before(:each) do
          PbsList.count.should == 0
          Provider.count.should == 0
          PbsListImporter.import_data(File.open("#{Rails.root}/spec/fixtures/data/pbs_list.csv"))
        end

        it "creates PbsList records from the data" do
          PbsList.count.should == 1
        end

        it "uses the given pbs_list_id for the PbsList record" do
          PbsList.first.pbs_list_id.should == '12'
        end

        it "creates a Provider record from the data (if necessary)" do
          Provider.count.should == 1
        end

        it "associates the provider record with the pbs record" do
          pbs_list = PbsList.first
          provider = Provider.first
          pbs_list.provider.should_not be_nil
          pbs_list.provider.should == provider
        end

      end
    end

    context "with existing provider records" do

      describe ".import_data" do

        before(:each) do
          @provider = Factory(:provider, :provider_id => '76', :psu_code => '20000030')
          PbsList.count.should == 0
          Provider.count.should == 1
          PbsListImporter.import_data(File.open("#{Rails.root}/spec/fixtures/data/pbs_list.csv"))
        end

        it "does not create any new Provider records" do
          Provider.count.should == 1
        end

        it "associates the existing provider record with the new PbsList record" do
          PbsList.first.provider.should == @provider
        end

      end

    end

    context "provider address" do
      describe ".import_data" do
        it "creates an Address record associated with the Provider" do
          Address.count.should == 0
          PbsListImporter.import_data(File.open("#{Rails.root}/spec/fixtures/data/pbs_list.csv"))
          Address.count.should == 1
          Provider.first.address.should_not be_blank
        end
      end
    end

  end
end
