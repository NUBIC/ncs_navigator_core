require 'spec_helper'

module Field::Adapters
  describe ResponseSet::ModelAdapter do
    let(:rs) { Factory(:response_set) }
    let(:adapter) { ResponseSet::ModelAdapter.new(rs) }

    describe '#pending_prerequisites' do
      describe 'if #source is not set' do
        before do
          adapter.source = nil
        end

        it 'is empty' do
          adapter.pending_prerequisites.should be_empty
        end
      end

      let(:ha) { ResponseSet::HashAdapter.new({}) }

      before do
        adapter.source = ha
      end

      it 'returns the survey public ID' do
        ha.survey_id = 'foo'

        adapter.pending_prerequisites[::Survey].should == ['foo']
      end

      it 'returns the participant public ID' do
        ha.p_id = 'bar'

        adapter.pending_prerequisites[::Participant].should == ['bar']
      end

      it 'returns the instrument public ID' do
        ia = Instrument::HashAdapter.new('instrument_id' =>  'baz')
        ha.ancestors = { :instrument => ia }

        adapter.pending_prerequisites[::Instrument].should == ['baz']
      end
    end
  end
end
