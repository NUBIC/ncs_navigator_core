require 'spec_helper'

module Field::Adapters
  describe Event::ModelAdapter do
    let(:adapter) { Event::ModelAdapter.new(e) }
    let(:e) { ::Event.new }
    let(:ha) { Event::HashAdapter.new({}) }
    let(:ca) { Contact::HashAdapter.new({'contact_id' => 'foo', 'person_id' => 'qux'}) }

    describe '#pending_prerequisites' do
      describe 'if source is nil' do
        before do
          adapter.source = nil
        end

        it 'is empty' do
          adapter.pending_prerequisites.should be_empty
        end
      end

      before do
        adapter.source = ha
      end

      it 'returns a participant public ID' do
        ha.p_id = 'foo'

        adapter.pending_prerequisites[::Participant].should == ['foo']
      end
    end

    describe '#ensure_prerequisites' do
      let(:p) { Factory(:participant, :p_id => 'foo') }

      let(:map) do
        Field::IdMap.new({
          ::Participant => { p.p_id => p.id }
        })
      end

      describe 'if source is nil' do
        before do
          adapter.source = nil
        end

        it 'returns true' do
          adapter.ensure_prerequisites(map).should be_true
        end
      end

      before do
        adapter.source = ha

        ha.p_id = 'foo'
      end

      it 'sets Event#participant_id' do
        adapter.ensure_prerequisites(map)

        e.participant_id.should == p.id
      end

      it 'returns true' do
        adapter.ensure_prerequisites(map).should be_true
      end
    end

    describe '#pending_postrequisites' do
      let!(:c) { Factory(:contact, :contact_id => ca.contact_id) }
      let!(:p) { Factory(:person, :person_id => ca.person_id) }

      describe 'if #source is not set' do
        before do
          adapter.source = nil
        end

        it 'is empty' do
          adapter.pending_prerequisites.should be_empty
        end
      end

      before do
        ha.ancestors = {
          :contact => ca
        }

        adapter.source = ha
        adapter.event_id = 'baz'
      end

      it 'contains a contact public ID' do
        adapter.pending_postrequisites[::Contact].should == ['foo']
      end

      it 'contains an event public ID' do
        adapter.pending_postrequisites[::Event].should == ['baz']
      end 

      it 'contains a person public ID' do
        adapter.pending_postrequisites[::Person].should == ['qux']
      end
    end

    describe '#ensure_postrequisites' do
      let!(:c) { Factory(:contact, :contact_id => ca.contact_id) }
      let!(:e) { Factory(:event, :event_id => 'bar') }
      let!(:p) { Factory(:person, :person_id => ca.person_id) }

      let(:map) do
        Field::IdMap.new({
          ::Contact => { ca.contact_id => c.id },
          ::Event => { 'bar' => e.id },
          ::Person => { ca.person_id => p.id }
        })
      end

      describe 'if #source is not set' do
        before do
          adapter.source = nil
        end

        it 'returns true' do
          adapter.ensure_postrequisites(map).should be_true
        end
      end

      before do
        ha.ancestors = {
          :contact => ca
        }

        adapter.source = ha
        adapter.event_id = e.event_id
        adapter.superposition = stub(:staff_id => 'foo')
      end

      it 'creates a ContactLink' do
        adapter.ensure_postrequisites(map)

        ContactLink.count.should == 1
      end

      describe 'if a suitable link exists' do
        before do
          ContactLink.create!(:contact => c, :event => e, :person => p, :staff_id => 'test')
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
