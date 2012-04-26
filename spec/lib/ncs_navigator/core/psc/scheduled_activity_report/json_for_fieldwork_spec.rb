# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core::Psc
  describe ScheduledActivityReport::JsonForFieldwork do
    subject { ScheduledActivityReport.new.extend(ScheduledActivityReport::JsonForFieldwork) }

    let(:c) { Factory(:contact) }
    let(:e) { Factory(:event) }
    let(:i) { Factory(:instrument, :response_set => rs) }
    let(:p) { Factory(:person) }
    let(:s) { Factory(:survey) }
    let(:rs) { Factory(:response_set) }

    let(:r1) do
      OpenStruct.new(:contact => c,
                     :event => e,
                     :instrument => i,
                     :person => p,
                     :survey => s)
    end

    before do
      subject.rows = [r1]
    end

    describe '#contacts_as_json' do
      let(:contacts) { subject.contacts_as_json }

      it 'skips rows without a contact' do
        r1.contact = nil

        contacts.should == []
      end

      it 'sets #/0/contact_id' do
        contacts[0]['contact_id'].should == subject.rows[0].contact.contact_id
      end

      it 'sets #/0/contact_date' do
        d = Date.new(2012, 1, 1)
        c.contact_date = d

        contacts[0]['contact_date'].should == d
      end

      it 'sets #/0/version' do
        contacts[0]['version'].should == subject.rows[0].contact.updated_at.utc
      end

      describe 'if contacts[0] has a start time' do
        before do
          c.contact_start_time = '12:00'
        end

        it 'sets #/0/start_time' do
          contacts[0]['start_time'].should == '12:00'
        end
      end

      describe 'if contacts[0] has a blank start time' do
        it 'sets #/0/start_time to nil' do
          contacts[0]['start_time'].should be_nil
        end
      end

      describe 'if contacts[0] has an end time' do
        before do
          c.contact_end_time = '12:00'
        end

        it 'sets #/0/end_time' do
          contacts[0]['end_time'].should == '12:00'
        end
      end

      describe 'if contacts[0] has a blank end time' do
        it 'sets #/0/end_time to nil' do
          contacts[0]['end_time'].should be_nil
        end
      end

      it 'sets #/0/disposition' do
        contacts[0]['disposition'].should == subject.rows[0].contact.contact_disposition
      end

      it 'sets #/0/events to [] if the row has no event' do
        r1.event = nil

        contacts[0]['events'].should == []
      end

      it 'sets #/0/events/0/event_id' do
        contacts[0]['events'][0]['event_id'].should == e.event_id
      end

      it 'sets #/0/events/0/name' do
        contacts[0]['events'][0]['name'].should == e.event_type.to_s
      end

      it 'sets #/0/events/0/version' do
        contacts[0]['events'][0]['version'].should == e.updated_at.utc
      end

      it 'sets #/0/events/0/disposition' do
        contacts[0]['events'][0]['disposition'].should == e.event_disposition
      end

      it 'sets #/0/events/0/disposition_category' do
        contacts[0]['events'][0]['disposition_category'].should == e.event_disposition_category_code
      end

      it 'sets #/0/events/0/start_date' do
        contacts[0]['events'][0]['start_date'].should == e.event_start_date
      end

      it 'sets #/0/events/0/start_time' do
        contacts[0]['events'][0]['start_time'].should == e.event_start_time
      end

      it 'sets #/0/events/0/end_date' do
        contacts[0]['events'][0]['end_date'].should == e.event_end_date
      end

      it 'sets #/0/events/0/end_time' do
        contacts[0]['events'][0]['end_time'].should == e.event_end_time
      end

      it 'sets #/0/events/0/instruments to [] if the row has no instruments' do
        r1.instrument = nil

        contacts[0]['events'][0]['instruments'].should == []
      end

      it 'sets #/0/events/0/instruments/0/instrument_id' do
        contacts[0]['events'][0]['instruments'][0]['instrument_id'].should ==
          i.instrument_id
      end

      it 'sets #/0/events/0/instruments/0/instrument_template_id' do
        contacts[0]['events'][0]['instruments'][0]['instrument_template_id'].should ==
          s.api_id
      end

      it 'sets #/0/events/0/instruments/0/name' do
        contacts[0]['events'][0]['instruments'][0]['name'].should ==
          s.title
      end

      it 'sets #/0/events/0/instruments/0/version' do
        contacts[0]['events'][0]['instruments'][0]['version'].should == i.updated_at.utc
      end

      it 'sets #/0/events/0/instruments/0/response_set' do
        contacts[0]['events'][0]['instruments'][0]['response_set'].should ==
          JSON.parse(i.response_set.to_json)
      end

      it 'sets #/0/person_id' do
        contacts[0]['person_id'].should == p.person_id
      end

      it 'sets #/0/type' do
        contacts[0]['type'].should == c.contact_type_code
      end
    end

    describe '#participants_as_json' do
      let(:json) { subject.participants_as_json }

      let(:participant) { Factory(:participant) }
      let(:other_person) { Factory(:person) }

      let(:cell) { Factory(:telephone, :phone_nbr => '123-456-7890') }
      let(:home) { Factory(:telephone, :phone_nbr => '987-654-3210') }
      let(:email) { Factory(:email, :email => 'foo@example.com') }
      let(:address) do
        Factory(:address, :city => 'Anywhere', :zip => '12345', :zip4 => '6789')
      end

      let(:link) do
        participant.participant_person_links.build(:person => other_person, :relationship_code => 1)
      end

      before do
        # NCS code infrastructure.
        create_missing_in_error_ncs_codes(Participant)
        Factory(:ncs_code, :list_name => 'PERSON_PARTCPNT_RELTNSHP_CL1', :local_code => 1)
        Factory(:ncs_code, :list_name => 'STATE_CL1', :local_code => 1)

        # Stub out the participant accessor in the row.
        r1.participant = participant

        # Link the participant to a person.
        link.save!

        # Set up information for the person.
        other_person.stub!(:primary_cell_phone => cell,
                           :primary_home_phone => home,
                           :primary_address => address,
                           :primary_email => email)
      end

      it 'emits one record per unique participant' do
        subject.rows = [r1, r1]

        json.length.should == 1
      end

      it 'does not raise an error if primary_cell_phone is nil' do
        other_person.stub!(:primary_cell_phone => nil)

        lambda { json }.should_not raise_error
      end

      it 'does not raise an error if primary_home_phone is nil' do
        other_person.stub!(:primary_home_phone => nil)

        lambda { json }.should_not raise_error
      end

      it 'does not raise an error if primary_address is nil' do
        other_person.stub!(:primary_address => nil)

        lambda { json }.should_not raise_error
      end

      it 'does not raise an error if primary_email is nil' do
        other_person.stub!(:primary_email => nil)

        lambda { json }.should_not raise_error
      end

      it 'sets #/0/p_id' do
        json[0]['p_id'].should == participant.p_id
      end

      it 'sets #/0/version' do
        json[0]['version'].should == participant.updated_at.utc
      end

      it 'sets #/0/persons/0/cell_phone' do
        json[0]['persons'][0]['cell_phone'].should == cell.phone_nbr
      end

      it 'sets #/0/persons/0/city' do
        json[0]['persons'][0]['city'].should == address.city
      end

      it 'sets #/0/persons/0/email' do
        json[0]['persons'][0]['email'].should == email.email
      end

      it 'sets #/0/persons/0/home_phone' do
        json[0]['persons'][0]['home_phone'].should == home.phone_nbr
      end

      it 'sets #/0/persons/0/name' do
        json[0]['persons'][0]['name'].should == other_person.name
      end

      it 'sets #/0/persons/0/person_id' do
        json[0]['persons'][0]['person_id'].should == other_person.person_id
      end

      it 'sets #/0/persons/0/relationship_code' do
        json[0]['persons'][0]['relationship_code'].should == link.relationship_code.to_i
      end

      it 'sets #/0/persons/0/state' do
        json[0]['persons'][0]['state'].should == address.state.display_text
      end

      it 'sets #/0/persons/0/street' do
        json[0]['persons'][0]['street'].should == [address.address_one, address.address_two].join("\n")
      end

      it 'sets #/0/persons/0/zip_code' do
        json[0]['persons'][0]['zip_code'].should == [address.zip, address.zip4].join('-')
      end

      it 'sets #/0/persons/0/version' do
        json[0]['persons'][0]['version'].should == other_person.updated_at.utc
      end
    end

    describe '#instrument_templates_as_json' do
      let(:templates) { subject.instrument_templates_as_json }

      it 'sets #/0/instrument_template_id' do
        templates[0]['instrument_template_id'].should == s.api_id
      end

      it 'sets #/0/version' do
        templates[0]['version'].should == s.updated_at.utc
      end

      it 'sets #/0/survey' do
        templates[0]['survey'].should == JSON.parse(s.to_json)
      end
    end
  end
end