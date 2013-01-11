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

    link.contact.contact_disposition = 510
    link.event.event_disposition = 510
    link.event.event_end_date = Date.today
    link.should be_closed
  end

  it { should belong_to(:psu) }
  it { should belong_to(:contact) }
  it { should belong_to(:person) }
  it { should belong_to(:event) }
  it { should belong_to(:instrument) }
  it { should belong_to(:provider) }

  it { should validate_presence_of(:staff_id) }

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

  describe "#contact_disposition" do

    it "returns an empty string if event is blank" do
      cl = Factory(:contact_link, :event => nil)
      cl.contact_disposition.should == ""
    end

    describe "with the general study category" do

      let(:general_study_cat) { NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 3) }
      let(:event) { Factory(:event, :event_disposition_category => general_study_cat) }

      it "'Completed Consent/Interview in English' for disposition 60" do
        contact = Factory(:contact, :contact_disposition => 60)
        link = Factory(:contact_link, :event => event, :contact => contact)
        link.contact_disposition.should == "Completed Consent/Interview in English"
      end

      describe "when DispositionMapper returns nil" do

        describe "and the contact_disposition is nil" do
          it "returns the contact_disposition" do
            contact = Factory(:contact, :contact_disposition => nil)
            link = Factory(:contact_link, :event => event, :contact => contact)
            link.contact_disposition.should be_nil
          end          
        end

        it "returns the contact_disposition" do
          contact = Factory(:contact, :contact_disposition => 1234) # 1234 is not a valid disposition
          link = Factory(:contact_link, :event => event, :contact => contact)
          link.contact_disposition.should == 1234
        end
      end

    end

    describe "with no event_disposition_category set" do
      it "returns the contact_disposition integer" do
        event = Factory(:event, :event_disposition_category => nil)
        contact = Factory(:contact, :contact_disposition => 60)
        link = Factory(:contact_link, :event => event, :contact => contact)
        link.contact_disposition.should == 60
      end
    end

  end
  
  context "exporting as csv" do
  
    person = Factory(:person)
    event = Factory(:event)
    instrument = Factory(:instrument, :event => event)
    contact = Factory(:contact)
    link = Factory(:contact_link, :person => person, :event => event, :contact => contact)

    it "renders in comma-separated value format" do

    link.to_comma.should == [
      link.contact.contact_type.to_s,
      link.contact.contact_date_date.to_s,
      link.contact.contact_start_time.to_s,
      link.contact.contact_end_time.to_s,
      link.person.first_name.to_s, 
      link.person.last_name.to_s,
      link.provider.to_s,
      link.contact_disposition.to_s,
      link.event.event_type.to_s,
      link.event_disposition.to_s,
      link.event.event_disposition_category.to_s,
      link.instrument.to_s,
      link.contact.contact_comment.to_s
    ]
    end

  end
end  

