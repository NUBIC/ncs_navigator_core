# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core
  describe RecordOfContactImporter do
    let(:importer) {
      RecordOfContactImporter.new(csv_io, :quiet => true)
    }

    let(:reference_csv) { Rails.root + 'spec/fixtures/data/ROC_Code_lists_and_Dispositions.csv' }

    let(:csv_header) {
      reference_csv.readlines.first
    }

    let(:exemplar_row) {
      Rails.application.csv_impl.read(reference_csv.open, :headers => true, :header_converters => :symbol).first
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

    def create_csv_row(value_map)
      exemplar_row.tap { |row|
        value_map.each do |header, value|
          row[header] = value
        end
      }
    end

    let(:csv_io) {
      created_file.open
    }

    let(:created_file) {
      Rails.root + 'tmp' + 'a.csv'
    }

    let!(:exemplar_participant) { Factory(:participant, :p_id => exemplar_row[:participant_id]) }

    def make_a_csv(*rows)
      created_file.open('w') do |f|
        f.write csv_header
        rows.each do |row|
          f.write row
        end
      end
    end

    def create_csv_row_text(value_map)
      create_csv_row(value_map).to_csv
    end

    describe "#import_data" do
      describe 'basic behavior' do
        let(:csv_io) {
          reference_csv.open
        }

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

      describe 'with consecutive contacts for the same event, omitting the start date on subsequent rows' do
        before do
          make_a_csv(
            create_csv_row_text(:event_start_date => '2010-07-06', :contact_date => '2010-07-06'),
            create_csv_row_text(:event_start_date => nil, :contact_date => '2010-07-11'),
            create_csv_row_text(:event_start_date => nil, :contact_date => '2010-07-20', :event_end_date => '2010-07-22'),
            create_csv_row_text(:event_start_date => '2010-09-03', :contact_date => '2010-09-03', :event_end_date => '2010-09-03')
          )

          importer.import_data
        end

        let(:event) { Event.where(:event_start_date => '2010-07-06').first }

        it 'creates only one event' do
          Event.where(:event_start_date => '2010-07-06').count.should == 1
        end

        it 'links all the contacts to the same event record' do
          event.contact_links.collect(&:contact).collect(&:contact_date).sort.should ==
            %w(2010-07-06 2010-07-11 2010-07-20)
        end

        it 'preserves the event start date from the first row' do
          Event.all.collect(&:event_start_date).sort.should == [
            Date.new(2010, 7, 6), Date.new(2010, 9, 3)
          ]
        end

        it 'takes the event end date from the last row' do
          event.event_end_date.should == Date.new(2010, 7, 22)
        end
      end

      describe 'with MDES code list values' do
        [
          [Event, :event_type,                 '5', '-15'],
          [Event, :event_breakoff,             '1', 'jazz'],
          [Event, :event_disposition_category, '1', '-10'],

          [Contact, :contact_type,      '-5', 'E'],
          [Contact, :contact_language,   '6', 'E'],
          [Contact, :contact_interpret,  '2', 'E'],
          [Contact, :contact_location,   '3', 'E'],
          [Contact, :contact_private,    '1', 'E'],
          [Contact, :who_contacted,      '3', 'E'],
        ].each do |model, coded_attribute, good_value, bad_value|
          describe "#{model}##{coded_attribute}" do
            it 'can use a code of the form {code}-{label}' do
              make_a_csv create_csv_row_text(coded_attribute => "#{good_value}-Foo!")
              importer.import_data

              model.first.send(coded_attribute).local_code.should == good_value.to_i
            end

            it 'can use a code of the form {code}' do
              make_a_csv create_csv_row_text(coded_attribute => good_value)
              importer.import_data

              model.first.send(coded_attribute).local_code.should == good_value.to_i
            end

            it 'fails for a bad value' do
              make_a_csv create_csv_row_text(coded_attribute => bad_value)

              expect { importer.import_data }.to raise_error(
                /Error on row 1. Unknown code value for #{model}##{coded_attribute}: #{bad_value}/
              )
            end
          end
        end
      end

      describe 'with bad data' do
        it 'fails for an unknown participant' do
          make_a_csv create_csv_row_text(:participant_id => 'No')

          expect { importer.import_data }.to raise_error /Error on row 1. Unknown participant "No"/
        end

        describe 'for event' do
          it 'does not accept a record which does not pass AR validations' do
            make_a_csv create_csv_row_text(:event_start_time => 'top-o-the-morn')

            expect { importer.import_data }.to raise_error /Error on row 1. Invalid Event: Event start time is invalid/
          end
        end

        describe 'for contact' do
          it 'does not accept a record which does not pass AR validations' do
            make_a_csv create_csv_row_text(:contact_start_time => 'top-o-the-morn')

            expect { importer.import_data }.to raise_error /Error on row 1. Invalid Contact: Contact start time is invalid/
          end
        end

        describe 'for contact link' do
          it 'does not accept a record which does not pass AR validations' do
            make_a_csv create_csv_row_text(:staff_id => nil)

            expect { importer.import_data }.to raise_error /Error on row 1. Invalid ContactLink: Staff can't be blank./
          end
        end

        describe 'in more than one type of record' do
          it 'reports them all' do
            make_a_csv(
              create_csv_row_text(:contact_start_time => 'top-o-the-morn', :event_start_time => 'dusk')
            )
            expect { importer.import_data }.to raise_error /Error on row 1. Invalid Event. Event start time is invalid.*Contact start time is invalid/m
          end
        end

        describe 'in more than one row' do
          it 'reports them all' do
            make_a_csv(
              create_csv_row_text(:contact_start_time => 'top-o-the-morn'),
              create_csv_row_text(:event_start_time => 'dusk')
            )
            expect { importer.import_data }.to raise_error /Error on row 1. Invalid Contact. Contact start time is invalid.*Error on row 2. Invalid Event: Event start time is invalid/m
          end
        end

        describe 'for another exception' do
          it 'reports a useful error' do
            ParticipantPersonLink.stub!(:create!).and_raise "I refuse"
            make_a_csv create_csv_row_text(:person_id => 'a new one', :relationship => '5')

            expect { importer.import_data }.to raise_error /Error on row 1. RuntimeError: I refuse.*record_of_contact_importer/m
          end
        end
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
  end
end
