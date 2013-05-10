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

describe AppointmentSheet, :shared_test_data do
  before :all do
    person = Factory(:person,
                     :person_id => "k47r-7z99-aw5e",
                     :first_name => "Samantha",
                     :last_name => "Edison")
    date = Date.parse("2013-04-08")

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

    participant_consent = Factory(:participant_consent,
                                  :consent_type_code => nil,
                                  :participant => participant)

    environmental_consent = Factory(:participant_consent_sample,
                                    :sample_consent_type => NcsCode.for_list_name_and_local_code('CONSENT_TYPE_CL2', 1),
                                    :participant_consent => participant_consent)

    biologicial_consent = Factory(:participant_consent_sample,
                                  :sample_consent_type_code => NcsCode.for_list_name_and_local_code('CONSENT_TYPE_CL2', 2),
                                  :participant_consent => participant_consent)

    ppg_detail = Factory(:ppg_detail,
                         :orig_due_date => '2012-10-10',
                         :participant => participant)

    contact1 = Factory(:contact,
                       :contact_date_date => Date.parse("2013-01-01"),
                       :contact_comment => "This is the first contact comment")

    contactlink1 = Factory(:contact_link,
                           :contact => contact1,
                           :person => person)

    contact2 = Factory(:contact,
                       :contact_date_date => Date.parse("2013-01-02"),
                       :contact_comment => "This is the second contact comment")

    contactlink2 = Factory(:contact_link,
                           :contact => contact2,
                           :person => person)

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

    child_consent = Factory(:participant_consent,
                            :consent_type_code => nil,
                            :participant => child_participant)

    child_biologicial_consent = Factory(:participant_consent_sample,
                                        :sample_consent_type_code => NcsCode.for_list_name_and_local_code('CONSENT_TYPE_CL2', 2),
                                        :participant_consent => child_consent)

    child_genetic_consent = Factory(:participant_consent_sample,
                                    :sample_consent_type_code => NcsCode.for_list_name_and_local_code('CONSENT_TYPE_CL2', 3),
                                    :participant_consent => child_consent)

    @sheet = AppointmentSheet.new(person, date)
    @missing_info_sheet = AppointmentSheet.new(Factory(:person), date)
  end

  it "has an event type" do
    @sheet.event_type.should == "6 Month"
  end

  it "prints 'unknown event' if event is nil" do
    @missing_info_sheet.event_type.should == "Unknown Event"
  end

  it "has an address" do
    @sheet.address.should eql(@address)
  end

  it "has cellular telephone" do
    @sheet.cell_phone.should == "301-908-1212"
  end

  it "cell phone returns nil if phone is nil" do
    @missing_info_sheet.cell_phone.should be_nil
  end

  it "has home telephone" do
    @sheet.home_phone.should == "301-999-5555"
  end

  it "home phone returns nil if phone is nil" do
    @missing_info_sheet.home_phone.should be_nil
  end

  it "has participant's name" do
    @sheet.participant_full_name.should == "Samantha Edison"
  end

  it "has a participant's public id" do
    @sheet.participant_public_id.should  match(/^[a-z0-9]{3}-[a-z0-9]{2}-[a-z0-9]{4}/)
  end

  it "has the language the participant speaks" do
    @sheet.participant_language.should == "English"
  end

  it "has all the mother's consents" do
    @sheet.mothers_consents.should == ["General", "Environmental Samples", "Biospecimens"]
  end

  it "has the children's names" do
    @sheet.child_names.should == ["Thomas Edison"]
  end

  it "has the children's sexes" do
    @sheet.child_sexes.should == ["Male"]
  end

  it "has the children's due dates" do
    @sheet.child_due_dates.should == ["10/10/2012"]
  end

  it "has the children's birth dates" do
    @sheet.child_birth_dates.should == ["09/03/2012"]
  end

  it "has the children's ages" do
    @sheet.child_ages.should == ["7 months"]
  end

  it "has the children's consents" do
    @sheet.child_consents.should == [["General", "Biospecimens", "Genetic Material"]]
  end

  it "has next event" do
    @sheet.next_event.should == "9 Month"
  end

  it "has the participant's children" do
    @sheet.children.should == [@child]
  end

  it "reports the last contact comment" do
    @sheet.last_contact_comment.should == "This is the second contact comment"
  end

  it "lists phase one consents for phase one participants" do
    person = Factory(:person)
    phase_one_participant = Factory(:participant)
    Factory(:participant_person_link,
            :person => person,
            :participant => phase_one_participant,
            :relationship_code => 1)
    (1..3).each do |type|
      Factory(:participant_consent,
              :consent_type => NcsCode.for_list_name_and_local_code('CONSENT_TYPE_CL1', type),
              :participant => phase_one_participant)
    end
    @sheet_with_phase_one_part = AppointmentSheet.new(person,
                                                      Date.parse("2013-04-08"))

    @sheet_with_phase_one_part.mothers_consents.should == ["General",
                                                           "Biospecimens",
                                                           "Environmental Samples"]
  end

end
