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

      it 'sets #/0/events to [] if the row has no event' do
        r1.event = nil

        contacts[0]['events'].should == []
      end

      it 'sets #/0/events/0/event_id' do
        contacts[0]['events'][0]['event_id'].should == e.event_id
      end

      it 'sets #/0/events/0/name' do
        contacts[0]['events'][0]['name'].should ==
          e.event_type.to_s
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

      it 'sets #/0/events/0/instruments/0/response_set' do
        contacts[0]['events'][0]['instruments'][0]['response_set'].should ==
          i.response_set
      end

      it 'sets #/0/person_id' do
        contacts[0]['person_id'].should == p.person_id
      end

      it 'sets #/0/type' do
        contacts[0]['type'].should == c.contact_type_code
      end
    end

    describe '#participants_as_json' do
      let(:participants) { subject.participants_as_json }
      let(:persons) { participants[0]['persons'] }

      it 'sets #/0/p_id' do
        participants[0]['p_id'].should == p.person_id
      end

      it 'sets #/0/persons/0/cell_phone'

      it 'sets #/0/persons/0/city'

      it 'sets #/0/persons/0/email'

      it 'sets #/0/persons/0/home_phone'

      it 'sets #/0/persons/0/name'

      it 'sets #/0/persons/0/person_id'

      it 'sets #/0/persons/0/relationship_code'

      it 'sets #/0/persons/0/state'

      it 'sets #/0/persons/0/street'

      it 'sets #/0/persons/0/zip_code'
    end

    describe '#instrument_templates_as_json' do
      let(:templates) { subject.instrument_templates_as_json }

      it 'includes each survey in the report' do
        templates.should == [s]
      end
    end
  end
end
