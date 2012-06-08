# == Schema Information
# Schema version: 20120607203203
#
# Table name: merges
#
#  id              :integer         not null, primary key
#  fieldwork_id    :integer
#  conflict_report :text
#  log             :text
#  proposed_data   :text
#  completed_at    :datetime
#  crashed_at      :datetime
#  started_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

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
      subject.stub!(:status => 'pending')

      json['status'].should == 'pending'
    end
  end

  describe '#status' do
    describe 'if started_at is nil' do
      before do
        subject.started_at = nil
      end

      describe 'and completed_at is nil' do
        before do
          subject.completed_at = nil
        end

        it 'is "pending"' do
          subject.status.should == 'pending'
        end
      end
    end

    describe 'if started_at is not nil' do
      before do
        subject.started_at = Time.now
      end

      describe 'and completed_at is nil' do
        before do
          subject.completed_at = nil
        end

        it 'is "working"' do
          subject.status.should == 'working'
        end

        describe 'and the job has timed out' do
          before do
            subject.started_at -= Merge::TIMEOUT
          end

          it 'is "timeout"' do
            subject.status.should == 'timeout'
          end
        end
      end

      describe 'and crashed_at is nil' do
        describe 'and the job has timed out' do
          before do
            subject.started_at -= Merge::TIMEOUT
          end

          it 'is "timeout"' do
            subject.status.should == 'timeout'
          end
        end
      end

      describe 'and crashed_at is not nil' do
        before do
          subject.crashed_at = Time.now
        end

        it 'is "error"' do
          subject.status.should == 'error'
        end
      end
    end

    describe 'if completed_at is not nil' do
      before do
        subject.completed_at = Time.now
      end

      describe 'and there are no conflicts' do
        before do
          subject.stub!(:conflicted? => false)
        end

        it 'is "merged"' do
          subject.status.should == 'merged'
        end
      end

      describe 'and there are conflicts' do
        before do
          subject.stub!(:conflicted? => true)
        end

        it 'is "conflict"' do
          subject.status.should == 'conflict'
        end
      end
    end
  end

  describe '#conflicted?' do
    describe 'if #conflict_report is nil' do
      before do
        subject.conflict_report = nil
      end

      it 'returns false' do
        subject.should_not be_conflicted
      end
    end

    describe 'if #conflict_report is {}' do
      before do
        subject.conflict_report = '{}'
      end

      it 'returns false' do
        subject.should_not be_conflicted
      end
    end

    describe 'if #conflict_report is non-empty' do
      before do
        subject.conflict_report = '{"Contact":{}}'
      end

      it 'returns true' do
        subject.should be_conflicted
      end
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
