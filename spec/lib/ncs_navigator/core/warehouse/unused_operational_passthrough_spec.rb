# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core::Warehouse
  describe UnusedOperationalPassthrough, :warehouse do
    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = File.join(Rails.root, 'log/wh.log')
        config.set_up_logs
        config.output_level = :quiet
      end
    }

    let(:passthrough) { UnusedOperationalPassthrough.new(wh_config) }

    describe '#create_emitter' do
      subject { passthrough.create_emitter }

      it 'includes PII' do
        subject.include_pii?.should be_true
      end

      it 'skips the ZIP' do
        subject.zip?.should be_false
      end

      it 'writes to a file in the importer_passthrough directory' do
        subject.filename.to_s.should =~
          %r(#{Rails.root}/importer_passthrough/operational-\d{14}.xml)
      end

      it 'uses the #contents' do
        NcsNavigator::Warehouse::XmlEmitter.should_receive(:new).
          with(anything, anything, include(:content => passthrough.contents))

        subject # trigger creation
      end
    end

    describe '#contents' do
      let(:contents) { passthrough.contents }

      let(:model_tables) { contents.models.collect(&:mdes_table_name) }

      it 'does not include models which are represented in the system' do
        model_tables.should_not include('person')
      end

      %w(
        staff staff_language staff_cert_training staff_weekly_expense
        staff_exp_mngmnt_tasks staff_exp_data_cllctn_tasks outreach
        outreach_lang2 outreach_race outreach_target outreach_eval
        outreach_staff
      ).each do |table|
        it "does not include #{table} since it is handled by Staff Portal" do
          model_tables.should_not include(table)
        end
      end

      %w(study_center psu ssu tsu).each do |table|
        it "does not include #{table} since it is handled by the runtime configuration" do
          model_tables.should_not include(table)
        end
      end

      it 'does include other operational models which are not represented in the system' do
        model_tables.should include('incident_media')
      end

      it 'does not include instrument models' do
        model_tables.should_not include('pre_preg')
      end

      it 'does not apply any default XML filters from the warehouse configuration' do
        wh_config.add_filter_set('bad filter', lambda { |recs| fail 'None shall pass' })
        wh_config.default_xml_filter_set = 'bad filter'

        contents.filters.filters.should be_empty
      end
    end

    describe '#import' do
      let(:mock_emitter) { mock(NcsNavigator::Warehouse::XmlEmitter) }

      it 'emits the XML' do
        passthrough.should_receive(:create_emitter).and_return(mock_emitter)
        mock_emitter.should_receive(:emit_xml)

        passthrough.import
      end
    end
  end
end
