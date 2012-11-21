require 'spec_helper'
require 'stringio'

module Psc
  describe ScheduledActivityReport do
    describe '.from_psc' do
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

        @report = ScheduledActivityReport.from_psc(psc, filters)
      end

      it "sets the report's filters" do
        @report.filters.should == data['filters']
      end
    end
  end
end
