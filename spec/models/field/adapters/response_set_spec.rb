# == Schema Information
# Schema version: 20130314152336
#
# Table name: response_sets
#
#  access_code                               :string(255)
#  api_id                                    :string(255)
#  completed_at                              :datetime
#  created_at                                :datetime
#  id                                        :integer          not null, primary key
#  instrument_id                             :integer
#  non_interview_report_id                   :integer
#  participant_consent_id                    :integer
#  participant_id                            :integer
#  processed_for_operational_data_extraction :boolean
#  started_at                                :datetime
#  survey_id                                 :integer
#  updated_at                                :datetime
#  user_id                                   :integer
#

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

      it 'returns the person public ID' do
        ha.person_id = 'baz'

        adapter.pending_prerequisites[::Person].should == ['baz']
      end

      it 'returns the instrument public ID' do
        ia = Instrument::HashAdapter.new('instrument_id' =>  'qux')
        ha.ancestors = { :instrument => ia }

        adapter.pending_prerequisites[::Instrument].should == ['qux']
      end
    end

    describe '#ensure_prerequisites' do
      let(:ha) { ResponseSet::HashAdapter.new({}) }
      let(:map) do
        Field::IdMap.new({
          ::Survey => { 'foo' => 1 },
          ::Participant => { 'bar' => 2 },
          ::Person => { 'baz' => 3 },
          ::Instrument => { 'qux' => 4 },
        })
      end

      before do
        ia = Instrument::HashAdapter.new('instrument_id' => 'qux')
        ha.survey_id = 'foo'
        ha.p_id = 'bar'
        ha.person_id = 'baz'
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

      it 'sets user_id from person_id' do
        adapter.ensure_prerequisites(map)

        rs.user_id.should == 3
      end

      it 'sets instrument_id' do
        adapter.ensure_prerequisites(map)

        rs.instrument_id.should == 4
      end

      it 'returns true if instrument_id, p_id, person_id, and survey_id were resolved' do
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

      it 'returns false if person_id was not resolved' do
        ha.person_id = 'bogus'

        adapter.ensure_prerequisites(map).should be_false
      end

      it 'returns false if survey_id was not resolved' do
        ha.survey_id = 'bogus'

        adapter.ensure_prerequisites(map).should be_false
      end
    end
  end
end
