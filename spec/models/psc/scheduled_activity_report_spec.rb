require 'spec_helper'

require File.expand_path('../../../shared/models/logger', __FILE__)

module Psc
  describe ScheduledActivityReport do
    include_context 'logger'

    let(:report) { ScheduledActivityReport.new(logger) }

    describe '#populate_from_psc' do
      let(:psc) { mock }

      let(:filters) do
        {
          :start_date => '2012-02-01',
          :end_date => '2012-03-01',
          :state => Psc::ScheduledActivity::SCHEDULED
        }
      end

      let(:data) do
        { 'filters' => {}, 'rows' => [] }
      end

      before do
        psc.should_receive(:scheduled_activities_report).
          with(:start_date => '2012-02-01', :end_date => '2012-03-01', :state =>
               Psc::ScheduledActivity::SCHEDULED).and_return(data)

        report.populate_from_psc(psc, filters)
      end

      it 'builds a ScheduledActivityCollection' do
        report.activities.should_not be_nil
      end

      it 'sets filters' do
        report.filters.should == data['filters']
      end
    end

    describe '#populate_from_schedule' do
      let(:data_file) { File.expand_path('../../../fixtures/psc/schedule_preview.json', __FILE__) }
      let(:data) { JSON.parse(File.read(data_file)) }

      before do
        report.populate_from_schedule(data)
      end

      it 'builds a ScheduledActivityCollection' do
        report.activities.should_not be_nil
      end
    end

    describe '#populate_from_report' do
      let(:data_file) { File.expand_path('../../../fixtures/psc/scheduled_activity_report.json', __FILE__) }
      let(:data) { JSON.parse(File.read(data_file)) }

      before do
        report.populate_from_report(data)
      end

      it 'sets filters' do
        report.filters.should_not be_nil
      end

      it 'sets activities' do
        report.activities.should_not be_nil
      end
    end

    describe '#dup' do
      let(:data_file) { File.expand_path('../../../fixtures/psc/scheduled_activity_report.json', __FILE__) }
      let(:data) { JSON.parse(File.read(data_file)) }

      before do
        report.populate_from_report(data)
      end

      it 'dups filters' do
        report.dup.filters.object_id.should_not == report.filters.object_id
      end

      it 'dups activities' do
        report.dup.activities.object_id.should_not == report.activities.object_id
      end
    end

    describe '#without_collection!' do
      let(:data_file) { File.expand_path('../../../fixtures/psc/scheduled_activity_report_with_collection.json', __FILE__) }
      let(:data) { JSON.parse(File.read(data_file)) }

      before do
        report.populate_from_report(data)
        report.without_collection!
      end

      it 'keeps non-collection activities' do
        report.activities.length.should == 1
      end
    end
  end
end
