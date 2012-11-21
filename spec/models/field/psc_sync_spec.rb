require 'spec_helper'

require File.expand_path('../../../shared/models/logger', __FILE__)
require File.expand_path('../superposition_with_test_data', __FILE__)

module Field
  describe PscSync do
    include_context 'superposition with test data'
    include_context 'logger'

    let(:merge) { ::Merge.new }

    before do
      superposition.extend(PscSync)
      superposition.logger = logger

      superposition.aker_configuration = Aker::Configuration.new do
        authority :cas
        cas_parameters :cas_base_url => 'https://cas.example.edu/cas'
      end
    end

    let(:sp) { superposition }

    # Sanity-preserving shortcut.
    def with_cas_success
      VCR.use_cassette('cas/machine_account_success') { yield }
    end

    describe '#login_to_psc' do
      describe 'on success' do
        around do |example|
          with_cas_success { example.run }
        end

        it 'returns a PatientStudyCalendar instance' do
          NcsNavigatorCore.suite_configuration.stub!(:core_machine_account_password => 'ncs_navigator_cases')

          sp.login_to_psc.should be_instance_of(PatientStudyCalendar)
        end
      end

      describe 'on failure' do
        around do |example|
          VCR.use_cassette('cas/machine_account_failure') { example.run }
        end

        it 'raises an error' do
          NcsNavigatorCore.suite_configuration.stub!(:core_machine_account_password => 'wrong')

          lambda { sp.login_to_psc }.should raise_error
        end
      end
    end

    describe '#prepare' do
      before do
        with_cas_success { sp.prepare_for_sync(merge) }
      end

      it 'sets up the sync key generator' do
        sp.keygen.should_not be_nil
      end

      it 'sets up the sync loader' do
        sp.sync_loader.should_not be_nil
      end

      it 'sets up the PSC importer' do
        sp.psc_importer.should_not be_nil
      end
    end

    describe 'the sync key generator' do
      before do
        merge.stub!(:id => 1)
        Time.stub!(:now => Time.at(1234567890.0))

        with_cas_success { sp.prepare_for_sync(merge) }
      end

      it 'generates Redis keys having prefix merge:merge id:start time' do
        sp.keygen['foo', 'bar'].should == 'merge:1:1234567890.0:foo:bar'
      end
    end

    describe '#load_for_sync', :needs_superposition_current_data do
      let(:redis) { Rails.application.redis }

      before do
        redis.flushdb

        with_cas_success { sp.prepare_for_sync(merge) }
      end

      it 'loads current participants' do
        sp.load_for_sync

        sp.sync_loader.cached_participant_ids.should == [participant_id]
      end

      it 'loads current events' do
        sp.load_for_sync

        sp.sync_loader.cached_event_ids.should == [event_id]
      end

      it 'loads current contact links' do
        c = Contact.where(:contact_id => contact_id).first
        e = Event.where(:event_id => event_id).first
        i = Instrument.where(:instrument_id => instrument_id).first
        cl = Factory(:contact_link, :contact => c, :event => e, :instrument => i)

        sp.load_for_sync

        sp.sync_loader.cached_contact_link_ids.should include(cl.public_id)
      end
    end

    describe '#sync_with_psc' do
      before do
        with_cas_success { sp.prepare_for_sync(merge) }
      end

      it 'tells OperationalImporterPscSync to import' do
        sp.psc_importer.should_receive(:import)

        sp.sync_with_psc
      end
    end
  end
end
