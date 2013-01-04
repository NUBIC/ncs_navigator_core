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
      end

      describe 'if Cases is set for specimen collection' do
        before do
          NcsNavigatorCore.configuration.stub!(:with_specimens? => true)

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

      describe 'if Cases is not set for specimen collection' do
        before do
          NcsNavigatorCore.configuration.stub!(:with_specimens? => false)

          etg.derive_models
        end

        # All event templates should still exist, even if they don't have any
        # instruments.
        it 'builds event templates' do
          etg.event_templates.length.should == 3
        end

        # There's five collection instruments in the sample data set, so we
        # expect three to remain post-filter.
        it 'does not build collection-related surveys' do
          etg.surveys.length.should == 3
        end

        # So we can filter surveys; that's good.  Instrument references from
        # event templates should also be fine.
        it 'does not insert unresolvable surveys in event templates' do
          instruments = etg.event_templates.map(&:instruments).flatten

          instruments.all? { |i| etg.surveys.include?(i.survey) }.should be_true
        end

        # Ditto on instrument plans.
        it 'does not insert unresolvable surveys in instrument plans' do
          surveys = etg.instrument_plans.map(&:surveys).flatten

          surveys.all? { |s| etg.surveys.include?(s) }.should be_true
        end
      end
    end

    shared_context 'response templates' do
      let(:templates) do
        YAML.load <<-END
pregnancy_visit_1:
  foo:
    - qref: bar
      aref: baz
      value: 1
  qux:
    - qref: quux
      aref: grault
garply:
  waldo:
    - qref: fred
      aref: plugh
        END
      end

      let!(:s1) { Factory(:survey, :title => 'foo') }
      let!(:s2) { Factory(:survey, :title => 'qux') }
    end

    describe '#build_response_templates' do
      include_context 'PSC mock'
      include_context 'response templates'

      before do
        etg.populate_from_psc(psc, date, activities)
        etg.derive_models
        etg.build_response_templates(templates)
      end

      # As mentioned above, we have the following events in the test data file:
      #
      # event:informed_consent
      # event:pregnancy_screener
      # event:pregnancy_visit_1
      #
      # The test data establishes response templates only for the last event,
      # so we expect one set of templates.
      it 'loads response templates for mentioned events' do
        etg.response_templates['pregnancy_visit_1'].should_not be_nil
      end

      it 'does not load events not in the selected template' do
        etg.response_templates['garply'].should be_nil
      end

      it 'resolves survey titles to API IDs' do
        ids = etg.response_templates['pregnancy_visit_1'].map { |rt| rt.survey_id }.uniq

        Set.new(ids).should == Set.new([s1.api_id, s2.api_id])
      end

      it 'builds one template per (survey, q, a) triple' do
        etg.response_templates['pregnancy_visit_1'].length.should == 2
      end
    end

    describe '#assign_response_templates' do
      include_context 'PSC mock'
      include_context 'response templates'

      before do
        etg.populate_from_psc(psc, date, activities)
        etg.derive_models
        etg.build_response_templates(templates)
        etg.assign_response_templates
      end

      it 'assigns templates for Pregnancy Visit 1 to events with label pregnancy_visit_1' do
        template = etg.event_templates.detect { |et| et.event.label == 'pregnancy_visit_1' }

        # the example data gives us two templates, one per survey
        template.response_templates.length.should == 2
      end

      it 'assigns an empty collection for events without response templates' do
        template = etg.event_templates.detect { |et| et.event.label == 'informed_consent' }

        template.response_templates.length.should == 0
      end
    end
  end
end
