require 'spec_helper'

module Field::Adapters
  describe ResponseSet::ModelAdapter do
    let(:rs) { ::ResponseSet.new }
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

    describe '#ensure_prerequisites' do
      let(:ha) { ResponseSet::HashAdapter.new({}) }
      let(:map) do
        Field::IdMap.new({
          ::Survey => { 'foo' => 1 },
          ::Participant => { 'bar' => 2 },
          ::Instrument => { 'baz' => 3 }
        })
      end

      before do
        ia = Instrument::HashAdapter.new('instrument_id' => 'baz')
        ha.survey_id = 'foo'
        ha.p_id = 'bar'
        ha.ancestors = { :instrument => ia }

        adapter.source = ha
      end

      it 'sets survey_id' do
        adapter.ensure_prerequisites(map)

        rs.survey_id.should == 1
      end

      it 'sets p_id' do
        adapter.ensure_prerequisites(map)

        rs.participant_id.should == 2
      end

      it 'sets instrument_id' do
        adapter.ensure_prerequisites(map)

        rs.instrument_id.should == 3
      end

      it 'returns true if instrument_id, p_id, and survey_id were resolved' do
        adapter.ensure_prerequisites(map).should be_true
      end

      it 'returns false if instrument_id was not resolved' do
        ha.ancestors = nil

        adapter.ensure_prerequisites(map).should be_false
      end

      it 'returns false if p_id was not resolved' do
        ha.p_id = 'bogus'

        adapter.ensure_prerequisites(map).should be_false
      end

      it 'returns false if survey_id was not resolved' do
        ha.survey_id = 'bogus'

        adapter.ensure_prerequisites(map).should be_false
      end
    end
  end
end
