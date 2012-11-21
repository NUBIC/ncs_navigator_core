require 'spec_helper'

require File.expand_path('../../../shared/models/logger', __FILE__)

module Field
  describe EventTemplateGenerator do
    include_context 'logger'

    let(:etg) { EventTemplateGenerator.new(logger) }

    describe '#templates' do
      describe 'for PBS' do
        before do
          NcsNavigatorCore.recruitment_strategy = ProviderBasedSubsample.new
        end

        it 'returns Pregnancy Visit 1' do
          etg.templates.should include(PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1)
        end

        it 'returns the PBS eligibility screener' do
          etg.templates.should include(PatientStudyCalendar::PBS_ELIGIBILITY_SCREENER)
        end
      end
    end

    describe '#populate_from_psc' do
      let(:data) { File.read(data_file) }
      let(:data_file) { File.expand_path('../../../fixtures/psc/schedule_preview.json', __FILE__) }
      let(:psc) { double }

      let(:date) { '2000-01-01' }
      let(:activities) { ['foo'] }

      before do
        psc.should_receive(:schedule_preview).with(date, activities).
          and_return(data)

        etg.populate_from_psc(psc, date, activities)
      end

      it 'builds a scheduled activity report' do
        etg.scheduled_activity_report.should_not be_nil
      end
    end
  end
end
