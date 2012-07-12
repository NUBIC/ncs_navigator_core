require 'spec_helper'

module Psc
  describe ScheduledActivityReport do
    let(:data) do
      JSON.parse(File.read(File.expand_path('../ex1.json', __FILE__)))
    end

    describe '.from_psc' do
      let(:psc) { mock }

      let(:filters) do
        {
          :start_date => '2012-02-01',
          :end_date => '2012-03-01',
          :state => PatientStudyCalendar::ACTIVITY_SCHEDULED
        }
      end

      before do
        psc.should_receive(:scheduled_activities_report).
          with(:start_date => '2012-02-01', :end_date => '2012-03-01', :state =>
               PatientStudyCalendar::ACTIVITY_SCHEDULED).and_return(data)

        @report = ScheduledActivityReport.from_psc(psc, filters)
      end

      it "sets the report's filters" do
        @report.filters.should == data['filters']
      end

      it "sets the report's rows" do
        @report.rows.should == data['rows']
      end
    end
  end
end
