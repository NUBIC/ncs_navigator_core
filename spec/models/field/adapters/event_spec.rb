require 'spec_helper'

module Field::Adapters
  describe Event::ModelAdapter do
    let(:adapter) { Event::ModelAdapter.new(e) }
    let(:e) { ::Event.new }
    let(:ha) { Event::HashAdapter.new({}) }

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
          ::Participant => { 'foo' => p }
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
  end
end
