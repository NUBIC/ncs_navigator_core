require File.expand_path('../../psc/example_data', __FILE__)

module Field
  describe ScheduledActivityReport do
    let(:report) { Field::ScheduledActivityReport.new }

    describe '#to_json' do
      R = Field::ScheduledActivityReport

      let(:json) { JSON.parse(report.to_json) }

      before do
        report.staff_id = 'test'

        report.process
      end

      describe 'return value' do
        it 'has a "contacts" key' do
          json.should have_key('contacts')
        end

        it 'has a "instrument_templates" key' do
          json.should have_key('instrument_templates')
        end
        
        it 'has a "participants" key' do
          json.should have_key('participants')
        end

        shared_context 'has a person' do
          let(:person) { Factory(:person) }
          let(:person_ir) do
            R::Person.new.tap do |p|
              p.model = person
            end
          end

          before do
            report.people << person_ir
          end
        end

        shared_context 'has a contact' do
          include_context 'has a person'

          let(:contacts) { json['contacts'] }
          let(:contact) { Factory(:contact) }
          let(:contact_ir) do
            R::Contact.new.tap do |c|
              c.person = person_ir
              c.model = contact 
            end
          end

          before do
            report.contacts << contact_ir
          end
        end

        describe 'contacts' do
          include_context 'has a contact'

          it 'sets #/0/contact_id to contact.public_id' do
            contacts[0]['contact_id'].should == contact.public_id
          end

          it 'sets #/0/contact_date_date to contact.contact_date' do
            contacts[0]['contact_date_date'].should == contact.contact_date
          end

          it 'sets #/0/contact_interpret_code to contact.contact_interpret_code' do
            contacts[0]['contact_interpret_code'].should == contact.contact_interpret_code
          end

          it 'sets #/0/contact_private_code to contact.contact_private_code' do
            contacts[0]['contact_private_code'].should == contact.contact_private_code
          end

          it 'sets #/0/who_contacted_code to contact.who_contacted_code' do
            contacts[0]['who_contacted_code'].should == contact.who_contacted_code
          end

          it 'sets #/0/version to contact.updated_at.utc' do
            contacts[0]['version'].should == contact.updated_at.utc.as_json
          end

          it 'sets #/0/contact_disposition to contact.contact_disposition' do
            contacts[0]['contact_disposition'].should == contact.contact_disposition
          end

          describe 'if the contact has a start time' do
            before do
              contact.contact_start_time = '12:00'
            end

            it 'sets #/0/contact_start_time' do
              contacts[0]['contact_start_time'].should == '12:00'
            end
          end

          describe 'if the contact has a blank start time' do
            it 'sets #/0/contact_start_time to nil' do
              contacts[0]['contact_start_time'].should be_nil
            end
          end

          describe 'if the contact has an end time' do
            before do
              contact.contact_end_time = '12:00'
            end

            it 'sets #/0/contact_end_time' do
              contacts[0]['contact_end_time'].should == '12:00'
            end
          end

          describe 'if the contact has a blank end time' do
            it 'sets #/0/end_time to nil' do
              contacts[0]['contact_end_time'].should be_nil
            end
          end

          it 'sets #/0/person_id' do
            contacts[0]['person_id'].should == person.person_id
          end

          it 'sets #/0/contact_type_code' do
            contacts[0]['contact_type_code'].should == contact.contact_type_code
          end
        end

        shared_context 'has an event' do
          include_context 'has a contact'

          let(:events) { json['contacts'][0]['events'] }
          let(:event) { Factory(:event) }
          let(:event_ir) do
            R::Event.new.tap do |e|
              e.model = event
              e.contact = contact_ir
              e.person = person_ir
            end
          end

          before do
            report.events << event_ir
          end
        end

        describe 'contacts.events' do
          include_context 'has a contact'

          describe 'if the report has no events for the contact' do
            it 'is []' do
              contacts[0]['events'].should == []
            end
          end

          describe 'if the report has an event for the contact' do
            include_context 'has an event'

            it 'sets #/0/event_id to event.public_id' do
              events[0]['event_id'].should == event.public_id
            end

            it 'sets #/0/events/0/name to the event type' do
              events[0]['name'].should == event.event_type.to_s
            end

            it 'sets #/0/version' do
              events[0]['version'].should == event.updated_at.utc.as_json
            end

            it 'sets #/0/disposition' do
              events[0]['disposition'].should == event.event_disposition
            end

            it 'sets #/0/event_disposition_category_code' do
              events[0]['event_disposition_category_code'].should == event.event_disposition_category_code
            end

            it 'sets #/0/event_start_date' do
              events[0]['event_start_date'].should == event.event_start_date
            end

            it 'sets #/0/event_start_time' do
              events[0]['event_start_time'].should == event.event_start_time
            end

            it 'sets #/0/event_end_date' do
              events[0]['event_end_date'].should == event.event_end_date
            end

            it 'sets #/0/event_end_time' do
              events[0]['event_end_time'].should == event.event_end_time
            end
          end
        end

        shared_context 'has an instrument' do
          include_context 'has an event'

          let(:instruments) { json['contacts'][0]['events'][0]['instruments'] }
          let(:instrument) { Factory(:instrument, :survey => survey, :response_set => response_set) }
          let(:response_set) { Factory(:response_set) }
          let(:survey) { Factory(:survey) }

          let(:survey_ir) do
            R::Survey.new.tap do |s|
              s.model = survey
            end
          end

          let(:instrument_ir) do
            R::Instrument.new.tap do |i|
              i.event = event_ir
              i.person = person_ir
              i.survey = survey_ir
              i.name = 'An instrument'
              i.model = instrument
            end
          end

          before do
            report.surveys << survey_ir
            report.instruments << instrument_ir
          end
        end

        describe 'events.instruments' do
          include_context 'has an event'

          describe 'if the report has no instruments for the event' do
            it 'is []' do
              events[0]['instruments'].should == []
            end
          end

          describe 'if the report has an instrument for the event' do
            include_context 'has an instrument'

            it 'sets #/0/instrument_id' do
              instruments[0]['instrument_id'].should == instrument.instrument_id
            end

            it 'sets #/0/instrument_template_id to survey.api_id' do
              instruments[0]['instrument_template_id'].should == survey.api_id
            end

            it 'sets #/0/response_set' do
              instruments[0]['response_set'].should == JSON.parse(response_set.to_json)
            end
          end
        end

        describe 'instrument_templates' do
          include_context 'has an instrument'

          let(:templates) { json['instrument_templates'] }

          it 'sets #/0/instrument_template_id' do
            templates[0]['instrument_template_id'].should == survey.api_id
          end

          it 'sets #/0/version' do
            templates[0]['version'].should == survey.updated_at.utc.as_json
          end

          it 'sets #/0/survey' do
            templates[0]['survey'].should == JSON.parse(survey.to_json)
          end
        end

        describe 'participants' do
          include_context 'has a person'

          let(:participants) { json['participants'] }
          let(:participant) { Factory(:participant) }
          let(:link) { participant.participant_person_links.build(:person => person, :relationship_code => 1) }

          before do
            link.save!
            person_ir.participant_model = participant
          end

          shared_examples_for 'a participant data generator' do
            it 'sets #/0/p_id' do
              participants[0]['p_id'].should == participant.p_id
            end

            it 'sets #/0/version' do
              participants[0]['version'].should == participant.updated_at.utc.as_json
            end

            it 'sets #/0/persons/0/name' do
              participants[0]['persons'][0]['name'].should == person.name
            end

            it 'sets #/0/persons/0/person_id' do
              participants[0]['persons'][0]['person_id'].should == person.person_id
            end

            it 'sets #/0/persons/0/relationship_code' do
              participants[0]['persons'][0]['relationship_code'].should == link.relationship_code.to_i
            end
          end

          describe 'with missing associated entities' do
            it_should_behave_like 'a participant data generator'
          end

          describe 'with associated entities' do
            let!(:cell) { Factory(:telephone, :phone_nbr => '123-456-7890', :person => person, :phone_rank_code => 1, :phone_type_code => Telephone.cell_phone_type.to_i) }
            let!(:home) { Factory(:telephone, :phone_nbr => '987-654-3210', :person => person, :phone_rank_code => 1, :phone_type_code => Telephone.home_phone_type.to_i) }
            let!(:email) { Factory(:email, :email => 'foo@example.com', :person => person, :email_rank_code => 1) }
            let!(:address) { Factory(:address, :city => 'Anywhere', :zip => '12345', :zip4 => '6789', :person => person, :address_rank_code => 1) }

            it_should_behave_like 'a participant data generator'

            it 'sets #/0/persons/0/cell_phone' do
              participants[0]['persons'][0]['cell_phone'].should == cell.phone_nbr
            end

            it 'sets #/0/persons/0/city' do
              participants[0]['persons'][0]['city'].should == address.city
            end

            it 'sets #/0/persons/0/email' do
              participants[0]['persons'][0]['email'].should == email.email
            end

            it 'sets #/0/persons/0/home_phone' do
              participants[0]['persons'][0]['home_phone'].should == home.phone_nbr
            end

            it 'sets #/0/persons/0/state' do
              participants[0]['persons'][0]['state'].should == address.state.display_text
            end

            it 'sets #/0/persons/0/street' do
              participants[0]['persons'][0]['street'].should == [address.address_one, address.address_two].join("\n")
            end

            it 'sets #/0/persons/0/zip_code' do
              participants[0]['persons'][0]['zip_code'].should == [address.zip, address.zip4].join('-')
            end

            it 'sets #/0/persons/0/version' do
              participants[0]['persons'][0]['version'].should == person.updated_at.utc.as_json
            end
          end
        end
      end
    end
  end
end
