require 'spec_helper'

require File.expand_path('../../../shared/models/logger', __FILE__)
require File.expand_path('../../../shared/custom_recruitment_strategy', __FILE__)

module Field
  describe EventTemplateGenerator do
    include_context 'logger'

    let(:etg) { EventTemplateGenerator.new(logger) }

    describe '#templates' do
      describe 'for PBS' do
        include_context 'custom recruitment strategy'

        let(:recruitment_strategy) { ProviderBasedSubsample.new }

        it 'returns Pregnancy Visit 1' do
          etg.templates.should include(PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1)
        end

        it 'returns the PBS eligibility screener' do
          etg.templates.should include(PatientStudyCalendar::PBS_ELIGIBILITY_SCREENER)
        end
      end
    end

    shared_context 'PSC mock' do
      let(:data) { JSON.parse(File.read(data_file)) }
      let(:data_file) { File.expand_path('../../../fixtures/psc/schedule_preview.json', __FILE__) }
      let(:psc) { double }

      let(:date) { '2000-01-01' }
      let(:activities) { ['foo'] }

      before do
        psc.should_receive(:schedule_preview).with(date, activities).
          and_return(data)
      end
    end

    describe '#populate_from_psc' do
      include_context 'PSC mock'

      before do
        etg.populate_from_psc(psc, date, activities)
      end

      it 'builds a scheduled activity report' do
        etg.scheduled_activity_report.should_not be_nil
      end
    end

    describe '#derive_models' do
      include_context 'PSC mock'

      before do
        etg.populate_from_psc(psc, date, activities)
        etg.derive_models
      end

      it 'builds event templates' do
        # At the time this test was written, these were the events in the test data file:
        #
        # spec/fixtures/psc$ ruby -e 'puts $stdin.read.scan(/event:\w+/).sort.uniq' < schedule_preview.json
        # event:informed_consent
        # event:pregnancy_screener
        # event:pregnancy_visit_1
        #
        # Update this test if you change the test data.
        etg.event_templates.length.should == 3
      end

      # The test data file has no references, so the most we're going to look
      # for here is "is it non-nil?"
      #
      # FIXME: This example is a bit worthless and should be fixed with better
      # test datasets.
      it 'builds instrument plans' do
        etg.instrument_plans.should_not be_nil
      end

      # As above:
      #
      # $ ruby -e 'puts $stdin.read.scan(/instrument:[^\s]+/).sort.uniq' < schedule_preview.json
      # instrument:2.0:ins_bio_adultblood_dci_ehpbhi_p2_v1.0
      # instrument:2.0:ins_bio_adulturine_dci_ehpbhi_p2_v1.0
      # instrument:2.0:ins_env_tapwaterpesttechcollect_dci_ehpbhi_p2_v1.0
      # instrument:2.0:ins_env_tapwaterpharmtechcollect_dci_ehpbhi_p2_v1.0
      # instrument:2.0:ins_env_vacbagdusttechcollect_dci_ehpbhi_p2_v1.0
      # instrument:2.0:ins_que_pregscreen_int_hili_p2_v2.0",
      # instrument:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0
      # instrument:2.0:ins_que_pregvisit1_saq_ehpbhi_p2_v2.0
      it 'builds surveys' do
        etg.surveys.length.should == 8
      end
    end
  end
end
