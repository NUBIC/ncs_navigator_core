# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: contact_links
#
#  contact_id       :integer          not null
#  contact_link_id  :string(36)       not null
#  created_at       :datetime
#  event_id         :integer
#  id               :integer          not null, primary key
#  instrument_id    :integer
#  person_id        :integer
#  provider_id      :integer
#  psu_code         :integer          not null
#  staff_id         :string(36)       not null
#  transaction_type :string(255)
#  updated_at       :datetime
#



require 'spec_helper'

describe ContactLink do

  it "creates a new instance given valid attributes" do
    link = Factory(:contact_link)
    link.should_not be_nil
  end

  it "knows when it is 'closed'" do
    link = Factory(:contact_link)
    link.should_not be_closed

    link.contact.contact_end_time = "12:00"
    link.event.event_end_date = Date.parse("2525-12-25")
    link.should be_closed
  end

  it { should belong_to(:contact) }
  it { should belong_to(:person) }
  it { should belong_to(:event) }
  it { should belong_to(:instrument) }
  it { should belong_to(:provider) }

  it { should validate_presence_of(:staff_id) }

  describe "#contact_disposition" do

    it "returns an empty string if event is blank" do
      cl = Factory(:contact_link, :event => nil)
      cl.contact_disposition.should == ""
    end

    # WIP - test other part of contact_disposition
    # participant = Factory(:participant)
    # person = Factory(:person)
    # event = Factory(:event, :participant => participant)
    # contact = Factory(:contact)

  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      link = Factory(:contact_link)
      link.public_id.should_not be_nil
      link.contact_link_id.should == link.public_id
      link.contact_link_id.length.should == 36
    end

  end

  it "knows about which participant this contact is regarding" do
    participant = Factory(:participant)
    person = Factory(:person)
    event = Factory(:event, :participant => participant)
    link = Factory(:contact_link, :person => person, :event => event)
    link.participant.should == participant
  end

end

