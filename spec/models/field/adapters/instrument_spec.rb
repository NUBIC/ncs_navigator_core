require 'spec_helper'

module Field::Adapters
  describe Instrument::ModelAdapter do
    let(:i) { ::Instrument.new }
    let(:adapter) { Instrument::ModelAdapter.new(i) }

    let(:ca) { Contact::HashAdapter.new({'contact_id' => 'foo', 'person_id' => 'qux'}) }
    let(:ea) { Event::HashAdapter.new({'event_id' => 'bar'}) }
    let(:ha) { Instrument::HashAdapter.new({'instrument_id' => 'baz'}) }

    describe '#pending_postrequisites' do
      describe 'if #source is not set' do
        before do
          adapter.source = nil
        end

        it 'is empty' do
          adapter.pending_postrequisites.should be_empty
        end
      end

      before do
        ha.ancestors = {
          :contact => ca,
          :event => ea
        }

        adapter.source = ha
        adapter.instrument_id = 'baz'
      end

      it 'contains a contact public ID' do
        adapter.pending_postrequisites[::Contact].should == ['foo']
      end

      it 'contains an event public ID' do
        adapter.pending_postrequisites[::Event].should == ['bar']
      end

      it 'contains an instrument public ID' do
        adapter.pending_postrequisites[::Instrument].should == ['baz']
      end

      it 'contains a person public ID' do
        adapter.pending_postrequisites[::Person].should == ['qux']
      end
    end

    describe '#ensure_postrequisites' do
      let!(:c) { Factory(:contact, :contact_id => ca.contact_id) }
      let!(:e) { Factory(:event, :event_id => ea.event_id) }
      let!(:i) { Factory(:instrument, :instrument_id => ha.instrument_id) }
      let!(:p) { Factory(:person, :person_id => ca.person_id) }

      let(:map) do
        Field::IdMap.new({
          ::Person => { ca.person_id => p.id },
          ::Instrument => { ha.instrument_id => i.id },
          ::Event => { ea.event_id => e.id },
          ::Contact => { ca.contact_id => c.id }
        })
      end

      describe 'if source is not set' do
        before do
          adapter.source = nil
        end

        it 'returns true' do
          adapter.ensure_postrequisites(map).should be_true
        end
      end

      before do
        ha.ancestors = {
          :contact => ca,
          :event => ea
        }

        adapter.source = ha
        adapter.instrument_id = 'baz'
        adapter.superposition = stub(:staff_id => 'foo')
      end

      it 'creates a ContactLink' do
        adapter.ensure_postrequisites(map)

        ContactLink.count.should == 1
      end

      it 'returns true' do
        adapter.ensure_postrequisites(map).should be_true
      end

      describe 'if a suitable link exists' do
        let(:c) { Factory(:contact, :contact_id => ca.contact_id) }
        let(:e) { Factory(:event, :event_id => ea.event_id) }
        let(:i) { Factory(:instrument, :instrument_id => ha.instrument_id) }
        let(:p) { Factory(:person, :person_id => ca.person_id) }

        before do
          ContactLink.create!(:contact => c,
                              :event => e,
                              :instrument => i,
                              :person => p,
                              :staff_id => 'test')
        end

        it 'does not create a ContactLink' do
          adapter.ensure_postrequisites(map)

          ContactLink.count.should == 1
        end

        it 'returns true' do
          adapter.ensure_postrequisites(map).should be_true
        end
      end

      describe 'on error' do
        let(:map) { Field::IdMap.new({}) }

        it 'returns false' do
          adapter.ensure_postrequisites(map).should be_false
        end
      end
    end
  end
end
