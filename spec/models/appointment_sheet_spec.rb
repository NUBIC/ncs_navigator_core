# == Schema Information
# Schema version: 20130409233256
#
# Table name: appointment_sheets
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  updated_at :datetime
#

require 'spec_helper'

describe AppointmentSheet do
  before do
    person = Factory(:person,
                     :person_id => "k47r-7z99-aw5e",
                     :first_name => "Samantha",
                     :last_name => "Edison")
    date = "2013-04-08"

    participant = Factory(:participant)

    Factory(:participant_person_link,
            :person => person,
            :participant => participant,
            :relationship_code => 1)

    event = Factory(:event,
                    :event_start_date => date,
                    :event_start_time => "13:30",
                    :event_type_code => 24, # 6-month
                    :participant => participant)

    next_event = Factory(:event,
                         :event_start_date => date,
                         :event_start_time => "13:30",
                         :event_type_code => 26, # 9-month
                         :participant => participant)

    @address = Factory(:address,
                       :address_rank_code => 1,
                       :address_one => "123 73rd Ave.",
                       :address_two => "Apt. 1C",
                       :city => "Rockville",
                       :state_code => 21,
                       :zip => "20850",
                       :person => person)

    cell_phone = Factory(:telephone,
                         :phone_nbr => "301-908-1212",
                         :phone_type_code => 3,
                         :phone_rank_code => 1,
                         :person => person)

    home_phone = Factory(:telephone,
                         :phone_nbr => "301-999-5555",
                         :phone_type_code => 1,
                         :phone_rank_code => 1,
                         :person => person)

    environmental_consent = Factory(:participant_consent_sample,
                                    :sample_consent_type_code => 1,
                                    :participant => participant)

    biologicial_consent = Factory(:participant_consent_sample,
                                  :sample_consent_type_code => 2,
                                  :participant => participant)

    consent = Factory(:participant_consent,
                      :consent_type_code => nil,
                      :participant_consent_samples => [biologicial_consent, environmental_consent],
                      :participant => participant)

    @child  = Factory(:person,
                      :first_name => "Thomas",
                      :last_name => "Edison",
                      :person_dob_date => Date.new(2012, 9, 3))

    child_participant = Factory(:participant)

    Factory(:participant_person_link,
            :person => @child,
            :participant => child_participant,
            :relationship_code => 1)

    Factory(:participant_person_link,
            :person => @child,
            :participant => participant,
            :relationship_code => 8)

    child_biologicial_consent = Factory(:participant_consent_sample,
                                        :sample_consent_type_code => 2,
                                        :participant => child_participant)

    child_genetic_consent = Factory(:participant_consent_sample,
                                    :sample_consent_type_code => 3,
                                    :participant => child_participant)

    consent = Factory(:participant_consent,
                      :consent_type_code => nil,
                      :participant_consent_samples => [child_biologicial_consent, child_genetic_consent],
                      :participant => child_participant)

    @sheet = AppointmentSheet.new(person.id.to_s)
  end

  it "has an event type" do
    @sheet.event_type.should == "6 Month"
  end

  it "has an address" do
    @sheet.address.should eql(@address)
  end

  it "has cellular telephone" do
    @sheet.cell_phone.should == "301-908-1212"
  end

  it "has home telephone" do
    @sheet.home_phone.should == "301-999-5555"
  end

  it "has participant's name" do
    @sheet.participant_full_name.should == "Samantha Edison"
  end

  it "has a participant's public id" do
    @sheet.participant_public_id.should == "k47r-7z99-aw5e"
  end

  it "has the language the participant speaks" do
    @sheet.participant_language.should == "English"
  end

  it "has all the mother's consents" do
    @sheet.mothers_consents.should == ["Biological", "Environmental"]
  end

  it "has the children's names" do
    @sheet.child_names.should == ["Thomas Edison"]
  end

  it "has the children's sexes" do
    @sheet.child_sexes.should == ["Male"]
  end

  it "has the children's ages" do
    @sheet.child_ages.should == ["7 months"]
  end

  it "has the children's consents" do
    @sheet.child_consents.should == [["Biological", "Genetic"]]
  end

  it "has next event" do
    @sheet.next_event.should == "9 Month"
  end

  it "has the participant's children" do
    @sheet.children.should == [@child]
  end

end
