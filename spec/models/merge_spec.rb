require 'spec_helper'

describe Merge do
  let!(:fw) { Factory(:fieldwork) }

  subject { fw.merges.build }

  describe '#run' do
    it 'saves the merge log' do
      subject.run

      subject.reload.log.should_not be_empty
    end
  end

  describe '#to_json' do
    let(:json) { JSON.parse(subject.to_json) }

    it 'includes its status' do
      subject.status = 'pending'

      json['status'].should == 'pending'
    end
  end

  describe '#schema_violations' do
    ##
    # The smallest possible valid fieldwork object.
    let(:valid) do
      { 'contacts' => [], 'participants' => [], 'instrument_templates' => [] }
    end

    let(:invalid) do
      {
        'contacts' => [
          {}
        ],
        'participants' => []
      }
    end

    describe 'if the original data is free of fieldwork schema violations' do
      before do
        fw.original_data = valid.to_json
      end

      it 'returns an empty array for original_data' do
        subject.schema_violations[:original_data].should == []
      end
    end

    describe 'if the original data has schema violations' do
      before do
        fw.original_data = invalid.to_json
      end

      it 'returns those violations' do
        subject.schema_violations[:original_data].should_not be_empty
      end
    end

    describe 'if #proposed_data is free of fieldwork schema violations' do
      before do
        subject.proposed_data = valid.to_json
      end

      it 'returns an empty array for proposed_data' do
        subject.schema_violations[:proposed_data].should == []
      end
    end

    describe 'if #proposed_data has schema violations' do
      before do
        subject.proposed_data = invalid.to_json
      end

      it 'returns those violations' do
        subject.schema_violations[:proposed_data].should_not be_empty
      end
    end

    describe 'if the original data and #proposed_data is blank' do
      before do
        fw.original_data = nil
        subject.proposed_data = nil
      end

      it 'does not raise an error' do
        lambda { subject.schema_violations }.should_not raise_error
      end
    end
  end
end
