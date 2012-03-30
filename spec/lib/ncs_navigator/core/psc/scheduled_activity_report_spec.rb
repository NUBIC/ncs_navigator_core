require 'spec_helper'

module NcsNavigator::Core::Psc
  describe ScheduledActivityReport do
    let(:report) do
      {
        'filters' => {
          'end_date' => '2012-03-01',
          'start_date' => '2012-02-01',
          'states' => ['Scheduled']
        },
        'rows' => []
      }
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
               PatientStudyCalendar::ACTIVITY_SCHEDULED).and_return(report)

        @report = ScheduledActivityReport.from_psc(psc, filters)
      end

      it 'returns a ScheduledActivityReport' do
        @report.should be_an_instance_of(ScheduledActivityReport)
      end

      it "sets the report's filters" do
        @report.filters.should == report['filters']
      end

      it "sets the report's rows" do
        @report.rows.should == report['rows']
      end
    end
  end
end
