# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core
  describe RecordOfContactImporter do
    let(:importer) {
      RecordOfContactImporter.new(csv_io)
    }

    let(:csv_io) {
      File.open("#{Rails.root}/spec/fixtures/data/ROC_Code_lists_and_Dispositions.csv")
    }

    def get_first_data_row_from_csv(csv)
      return_value = nil
      f = File.open("#{Rails.root}/spec/fixtures/data/#{csv}.csv")
      Rails.application.csv_impl.parse(f, :headers => true, :header_converters => :symbol) do |row|
        next if row.header_row?
        return_value = row
      end
      return_value
    end

    describe "#import_data" do

      before(:each) do
        # create Participants and a particular participant for an exisiting record
        [11111111, 22222222, 11112222, 22221111, 33333333].each { |id| Participant.create :p_id => id }
        participant = Participant.where(:p_id => '11111111').first

        # create a Person
        person = Person.create! :person_id => 11111111

        # create an event associated with a the particular participant
        event = Event.new :event_type_code => 15, :event_start_date => '2012-04-10'
        event.participant = participant
        event.save!

        # create a contact with a colliding date and time
        contact = Contact.create!(:contact_date_date => Date.parse('2012-04-10'), :contact_start_time => '15:00')

        # create a contact link to bring the contact together with the person and event
        ContactLink.create!(:person => person, :event => event, :contact => contact, :staff_id => 1)
      end

      it "creates a participant-person link if the person record is new and the relationship field is not blank" do
        ParticipantPersonLink.count == 0
        importer.import_data
        ParticipantPersonLink.count == 1
      end

      it "finds a person if one exists or creates one if it doesn't" do
        Person.count.should == 1
        importer.import_data
        Person.count.should == 5
      end

      it "finds an event if one exists or creates one if it doesn't" do
        Event.count.should == 1
        importer.import_data
        Event.count.should == 5
      end

      it "finds a contact if one exists or creates one if it doesn't" do
        Contact.count.should == 1
        importer.import_data
        Contact.count.should == 5
      end

      it "creates a ContactLink from the data" do
        ContactLink.count.should == 1
        importer.import_data
        ContactLink.count.should == 5
      end

      it "associates a ContactLink with a Person, Event, and Contact" do
        person = Person.first
        contact = Contact.first
        event = Event.first
        ContactLink.first.person.should == person
      end

    end

    context "#get_person_record" do

      context "with an existing person record" do

        let(:person) { Factory(:person, :person_id => "bob") }

        it "finds the record by person_id" do
          row = get_first_data_row_from_csv("existing_person")
          person.person_id.should == row[:person_id]
          importer.get_person_record(row).should == person
        end

        it "sets the first name if given in row" do
          row = get_first_data_row_from_csv("existing_person")
          person.first_name.should == "Fred"
          person = importer.get_person_record(row)
          person.first_name.should == "Bobby"
        end

        it "does not update first name if the data in the row first name is blank" do
          row = get_first_data_row_from_csv("existing_person_with_blank_name")
          person.first_name.should == "Fred"
          person = importer.get_person_record(row)
          person.first_name.should == "Fred"
        end

      end

      context "without an existing person record" do

        before(:each) do
          @row = get_first_data_row_from_csv("existing_person_with_blank_name")
        end

        it "builds a new person record if no person exists" do
          person = importer.get_person_record(@row)
          person.class.should == Person
        end

      end
    end

    context ".contact_link_missing_participant_log" do

      it "prints a log if the participant in the records does not exist in the database"  do
        contents = []
        f = File.open("#{Rails.root}/log/contact_link_missing_participant_logs/test_missing_participant.log", 'r') do |infile|
          while(line = infile.gets)
            contents << line
          end
        end
        contents.should include("[2012-06-29 16:27:26] contact_link record error: -> participant [33332222] missing in row - 2000058,60,1,,4/11/2012,17:00,17:40,1,,,,1,,1,1,,33332222,24,,60,3,4/11/2012,17:40,2,,96539006,33332222,,,\n")
      end

    end
  end

end
