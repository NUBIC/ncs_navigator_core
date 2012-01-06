# == Schema Information
# Schema version: 20111212224350
#
# Table name: contact_links
#
#  id               :integer         not null, primary key
#  psu_code         :integer         not null
#  contact_link_id  :string(36)      not null
#  contact_id       :integer         not null
#  event_id         :integer
#  instrument_id    :integer
#  staff_id         :string(36)      not null
#  person_id        :integer
#  provider_id      :integer
#  transaction_type :string(255)
#  created_at       :datetime
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
    link.should be_closed
  end

  it { should belong_to(:psu) }
  it { should belong_to(:contact) }
  it { should belong_to(:person) }
  it { should belong_to(:event) }
  it { should belong_to(:instrument) }
  # it { should belong_to(:provider) }

  it { should validate_presence_of(:staff_id) }
  it { should validate_presence_of(:contact_id) }

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
