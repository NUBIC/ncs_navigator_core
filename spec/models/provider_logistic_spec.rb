# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: provider_logistics
#
#  comment                  :text
#  completion_date          :date
#  created_at               :datetime
#  id                       :integer          not null, primary key
#  provider_id              :integer
#  provider_logistics_code  :integer          not null
#  provider_logistics_id    :string(36)       not null
#  provider_logistics_other :string(255)
#  psu_code                 :integer          not null
#  refusal                  :boolean
#  transaction_type         :string(255)
#  updated_at               :datetime
#

require 'spec_helper'

describe ProviderLogistic do
  it "should create a new instance given valid attributes" do
    pl = Factory(:provider_logistic)
    pl.should_not be_nil
  end

  it { should belong_to(:provider) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pl = Factory(:provider_logistic)
      pl.public_id.should_not be_nil
      pl.provider_logistics_id.should == pl.public_id
      pl.provider_logistics_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      pl = ProviderLogistic.new
      pl.psu_code = 20000030
      pl.save!

      obj = ProviderLogistic.first
      obj.provider_logistics.local_code.should == -4
    end
  end

end
